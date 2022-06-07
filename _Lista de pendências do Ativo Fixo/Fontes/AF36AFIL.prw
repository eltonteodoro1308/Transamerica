#include 'totvs.ch'

/*/{Protheus.doc} AF36AFIL
Ponto de entrada que cria filtros de ativos para sele��o na tela de baixa de ativo em lote.
Pega da pergunta a lista separada por v�rgulas e intervalos por tra�o e monta filtro para a query.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 31/05/2022
@return charactere, Filtro definido na pergunta.
/*/
user function AF36AFIL

	Local cLstBens   := StrTran( MV_PAR13, " ", "" )
	Local cRet       := ' 1 = 1 '
	Local aAux       := {}
	Local aInFormat  := {}
	Local cInFormat  := ''
	Local aBetween   := {}
	Local cBetween   := ''
	Local nX         := 0

	if ! Empty( cLstBens )

		/* Popula array com a lista de c�digo a serem filtrados */

		aAux := StrTokArr2( cLstBens, ',', .T. )

		/* Separa em listas diferentes o que � intervalo separado por tra�o e  o que n�o �. */

		for nX := 1 to len( aAux )

			if aT( '-', aAux[ nX ] ) > 0

				aAdd( aBetWeen, StrTokArr2( aAux[ nX ], '-', .T. ) )

			else

				aAdd( aInFormat, aAux[ nX ] )

			end if

		next nX

		/* Percorre a lista de intervalos definidos e monta as instru��es "BETWEEN�s" */

		for nX := 1 to len( aBetWeen )

			cBetween += " N1_CBASE BETWEEN '" + aBetWeen[ nX, 1 ] + "' AND '" + aBetWeen[ nX, 2 ] + "' "

			if len( aBetWeen ) > nX

				cBetween += " OR "

			end if

		next nX

		/* Percorre a lista de c�digos individuais e monta  */

		for nX := 1 to len( aInFormat )

			cInFormat += "'" + aInFormat[ nX ] + "'"

			if len( aInFormat ) > nX

				cInFormat += ","

			end if

			if len( aInFormat ) == nX

				cInFormat := " N1_CBASE IN( " + cInFormat + " ) "

			end if

		next nX

		/* Monta o filtro a ser retornado verificando se h� intervalos de c�digos e c�digos individuais */

		if ! Empty( cInformat ) .And. ! Empty( cBetween )

			cRet := cInformat + ' OR ' + cBetween

		elseIf ! Empty( cInformat ) .And. Empty( cBetween )

			cRet := cInformat

		elseIf Empty( cInformat ) .And. ! Empty( cBetween )

			cRet := cBetween

		end if

	endIf

	cRet := "( " + cRet + " )"

return cRet
