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
	local cSeek      := ''
	local nPos       := 0
	local aArea      := getArea()

	aEval( aAux, { | item |;
		aItem := StrTokArr2( item, '=', .T. ),;
		aAdd( aMotCod, AllTrim( aItem[1] ) ),;
		aAdd( aMotDesc, AllTrim( aItem[2] ) ) } )

	if ! Empty( SN1->N1_BAIXA )

		DbSelectArea( 'FN7' )
		FN7->( DBOrderNickname( 'BAIXATOTAL' ) ) // FN7_FILIAL+FN7_MOEDA+FN7_CBASE+FN7_CITEM+FN7_TIPO+FN7_DTBAIX

		cSeek := SN1->( N1_FILIAL + '01' + N1_CBASE + N1_ITEM + '01' + dTos( N1_BAIXA ) )

		if FN7->( DbSeek( cSeek ) .And.;
				cSeek == FN7_FILIAL + FN7_MOEDA + FN7_CBASE + FN7_CITEM + FN7_TIPO + dTos( FN7_DTBAIX ) )

			nPos := aScan( aMotCod, FN7->FN7_MOTIVO )

			cRet := aMotDesc[ nPos ]

			FN7->( DbCloseArea() )

		end if

		DbSelectArea( 'SN4' )
		SN4->( DbSetOrder( 1 ) ) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ

		cSeek := SN1->( N1_FILIAL + N1_CBASE + N1_ITEM + '01' + dTos( N1_BAIXA ) + '15' )

		if SN4->( DbSeek( cSeek ) .And.;
				cSeek == N4_FILIAL + N4_CBASE + N4_ITEM + N4_TIPO + DTOS(N4_DATA) + N4_OCORR )

				cRet := 'Baixa por aquisição de transferência'

		end if

	end if

	restArea( aArea )

return cRet

