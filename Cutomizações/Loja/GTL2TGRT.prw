#include 'totvs.ch'
/*/{Protheus.doc} GTL2TGRT
Gatilho aplicado ao campo LR_PRODUTO, com a finalidade de buscar no campo LG_XLOCPAD
do cadastro de esta��o o local onde deve ser baixado o produto da venda.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 24/11/2021
@return character, C�digo do local de estoque
/*/
User Function GTL2TGRT(cvar)

	Local nPosLocal := aScan( aHeaderDet, { |x| Trim(x[2]) == 'LR_LOCAL' })
	Local cLocal    := locEst() //C�digo do Armaz�m

	If Len(aColsDet) >= n
		aColsDet[n][nPosLocal] := cLocal //C�digo do Armaz�m
	Endif

Return cLocal

/*/{Protheus.doc} locEst
Busca no cadastro da esta��o da Venda o local de estocagem.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 11/11/2021
@return character, local de estocagem no cadastro da esta��o
/*/
static function locEst()

	local cAlias := GetNextAlias()
	local cRet   := ''
	local aArea  := GetArea()

	BeginSql Alias cAlias
    
    SELECT LG_XLOCPAD FROM %TABLE:SLG%
    WHERE LG_FILIAL = %EXP:cFilAnt%
    AND LG_CODIGO = %EXP:cEstacao%
	AND %NOTDEL%
    
	EndSql

	cRet := ( cAlias )->LG_XLOCPAD

	( cAlias )->( DbCloseArea() )

	RestArea( aArea )

return cRet
