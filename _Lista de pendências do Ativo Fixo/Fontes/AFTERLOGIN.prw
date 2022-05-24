#include 'totvs.ch'

/*/{Protheus.doc} afterLogin
Este ponto de entrada é executado após as aberturas dos SXs(dicionário de dados).
Ao acessar pelo SIGAMDI, este ponto de entrada é chamado ao entrar na rotina. 
Pelo modo SIGAADV, a abertura dos SXs é executado após o login.
@obs Este ponto de entrada foi implenmentado para atribuir ao comando de atalho CRTL + k
a execução da função que faz o rateio do bem pela quantidade na tela de distribuiçaõ por 
percentual e também preenche incrementalmente o código base e plaqueta, mantendo o código
do item igual, com os valores informados na primeira linha.
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 08/12/2021
/*/
user function afterLogin()

	// Define que o comando CRTL + K chamará a funcção procRat
	SetKey ( K_CTRL_K, {|| procRat() } )

return

/*/{Protheus.doc} procRat
Função evocada pelo comando CTRL + K
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 08/12/2021
/*/
static function procRat()

	Local nX         := 1
	Local nQuantd    := 0
	Local nVlAquis   := 0
	Local nPercRat   := 0
	Local nVlRat     := 0
	Local cCbase     := ''
	Local cItem      := ''
	Local cChapa     := ''
	Local lNaoRepChp := MV_PAR03 == 2 // Não repete chapa

	/******************************************************************************
	Verifica se a chamada é feita na tela de distribuição de valores por percentual
   ********************************************************************************/
	if FwIsInCallStack('AF251DIST') .And. ApMsgYesNo ( 'Este bem será divido em '+;
			cValToChar(SN1->N1_QUANTD) +' partes, prossegue ?', 'AF251DIST' )

		nQuantd  := SN1->N1_QUANTD
		nVlAquis := SN1->N1_VLAQUIS
		nPercRat := 100 / nQuantd
		nVlRat   := nVlAquis / nQuantd

		aSize( oGetDist:aCols, 0 )

		for nX := 1 To nQuantd

			oGetDist:AddLine(.T.)

			GDFieldPut( "NV_PERCEN", nPercRat, oGetDist:nAt, oGetDist:aHeader ,oGetDist:aCols )
			GDFieldPut( "N3_VORIG1", nVlRat  , oGetDist:nAt, oGetDist:aHeader ,oGetDist:aCols )

			oGetDist:LinhaOk(.T.,.T.)

		next nX

		ApMsgInfo( 'Divisão processada.', 'AF251DIST' )

	endIf
   
   /**********************************************************
	Verifica se a chamada é feita na tela de rateio de valores
   ***********************************************************/
	if FwIsInCallStack('AF251RATEIO') .And. ApMsgYesNo ( ;
			'Os bens terão o Código base e a Plaqueta incremantados e o ' +;
			'Item repetidos a partir dos valores da primeira linha, prossegue ?',;
			'AF251RATEIO' )

		cCbase := AllTrim( GDFieldGet ( 'N1_CBASE', 1 ) )
		cItem  := GDFieldGet ( 'N1_ITEM' , 1 )
		cChapa := AllTrim( GDFieldGet ( 'N1_CHAPA', 1 ) )

		if lNaoRepChp .And. Empty( cChapa )

			ApMsgStop( 'Informe um código de plaqueta/chapa válido.', 'AF251RATEIO' )

			return

		endIf

		while .T.

			if ExistCod( cCbase, 1 )

				cCbase := soma1( cCbase )

			else

				if lNaoRepChp .And. ExistCod( cChapa, 2 )

					cChapa := soma1( cChapa )

				else

					GDFieldPut( "N1_CBASE", PadR( cCbase, TamSx3( "N1_CBASE" )[1] ), nX )
					GDFieldPut( "N1_ITEM" , PadR( cItem,  TamSx3( "N1_ITEM"  )[1] ), nX )
					GDFieldPut( "N1_CHAPA", PadR( cChapa, TamSx3( "N1_CHAPA" )[1] ), nX )

					cCbase := soma1( cCbase )
					cChapa := soma1( cChapa )

					nX++

				endIf

			endIf

			if nX > len( aCols )

				Exit

			endIf

		endDo

	endIf

return

/*/{Protheus.doc} ExistCod
Verifica se o código base ou a plaqueta já existem no cadastro
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 08/12/2021
@param cCodigo, character, Código base ou código da plaqueta
@param nIndice, numeric, indice a ser utilizado na busca, 1 para código base e 2 para plaqueta
@return logical, indica se o código existe ou não na base.
/*/
static function ExistCod( cCodigo, nIndice )

	local aArea    := getArea()
	local aAreaSN1 := SN1->( getArea() )
	local lRet     := .F.

	SN1->( DbSetOrder( nIndice ) )

	SN1->( lRet := DbSeek( xFilial() + cCodigo ) )

	SN1->( restArea( aAreaSN1 ) )

	restArea( aArea )

return lRet
