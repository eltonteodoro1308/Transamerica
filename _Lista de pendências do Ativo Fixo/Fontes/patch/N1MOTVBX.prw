#include 'totvs.ch'

/*/{Protheus.doc} N1MOTVBX
Função a ser utilizada no inicializador padrão e incializador do browse do campo N1_XMOTVBX
que indica o motivo de baixa do bem.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 24/05/2022
@return charactere, Motivo de baixa do bem
/*/
user function N1MOTVBX()

	local cRet       := ''
	local aMotCod    := {}
	local aMotDesc   := {}
	local aAux       := StrTokArr2( AllTrim( AF036ValMot() ) , ';', .T. )
	local cSeek      := SN1->( N1_FILIAL + '1  ' + N1_CBASE + N1_ITEM + '01' + dTos( N1_BAIXA ) )
	local nPos       := 0

	aEval( aAux, { | item |;
		aItem := StrTokArr2( item, '=', .T. ),;
		aAdd( aMotCod, AllTrim( aItem[1] ) ),;
		aAdd( aMotDesc, AllTrim( aItem[2] ) ) } )

	if ! Empty( SN1->N1_BAIXA )

		DbSelectArea( 'FN7' )
		FN7->( DBOrderNickname( 'BAIXATOTAL' ) ) // FN7_FILIAL+FN7_ITEM+FN7_CBASE+FN7_CITEM+FN7_TIPO+FN7_DTBAIX

		if FN7->( DbSeek( cSeek ) .And.;
				cSeek == FN7_FILIAL + FN7_ITEM + FN7_CBASE + FN7_CITEM + FN7_TIPO + dTos( FN7_DTBAIX ) )

			nPos := aScan( aMotCod, FN7->FN7_MOTIVO )

			cRet := aMotDesc[ nPos ]

			FN7->( DbCloseArea() )

		end if

	end if

return cRet
/* 
	local aArea      := nil
	local lSn3InArea := ! Select( 'SN3' ) == 0
	local cFil       := SN1->N1_FILIAL
	local cCBase     := SN1->N1_CBASE
	local cItem      := SN1->N1_ITEM

	if lSn3InArea

		aArea := SN3->( getArea() )

	else

		DbSelectArea( 'SN3' )

	end if

	SN3->( DbSetOrder( 1 ) )

	if SN3->( DbSeek( cFil + cCBase + cItem + '01' )  .And.;
			N3_FILIAL + N3_CBASE + N3_ITEM + N3_TIPO  == cFil + cCBase + cItem + '01' )

		if ! Empty( SN1->N1_BAIXA )

			cRet := 'Baixado'

		elseIf SN3->( N3_VORIG1 + N3_AMPLIA1 - N3_VRDACM1) <= 0

			cRet := 'Depreciado'

		elseIf SN1->N1_STATUS == '0'

			cRet := 'Pendente de Classificação'

		elseIf SN1->( ! Empty( N1_DTBLOQ ) .And. N1_DTBLOQ > Date() )

			cRet := 'Bloqueado'

		elseIf SN3->(;
				DbSeek( cFil + cCBase + cItem + '010' )  .And.;
				N3_FILIAL + N3_CBASE + N3_ITEM + N3_TIPO  + N3_BAIXA == cFil + cCBase + cItem + '010'  .And.;
				DbSeek( cFil + cCBase + cItem + '011' )  .And.;
				N3_FILIAL + N3_CBASE + N3_ITEM + N3_TIPO  + N3_BAIXA == cFil + cCBase + cItem + '011' )

			cRet := 'Ativo (Parcialmente Baixado)'

		end if

	end if

	if lSn3InArea

		SN3->( restArea( aArea ) )

	else

		SN3->( DbCloseArea() )

	end if */

