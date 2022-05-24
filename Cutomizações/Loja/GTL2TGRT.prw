#include 'totvs.ch'
/*/{Protheus.doc} GTL2TGRT
Gatilho aplicado ao campo LR_PRODUTO, com a finalidade de buscar no campo LG_XLOCPAD
do cadastro de estação o local onde deve ser baixado o produto da venda.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 24/11/2021
@return character, Código do local de estoque
/*/
User Function GTL2TGRT(cvar)

	Local nPosLocal := aScan( aHeaderDet, { |x| Trim(x[2]) == 'LR_LOCAL' })
	Local cLocal    := locEst() //Código do Armazém

	If Len(aColsDet) >= n
		aColsDet[n][nPosLocal] := cLocal //Código do Armazém
	Endif

Return cLocal

/*/{Protheus.doc} locEst
Busca no cadastro da estação da Venda o local de estocagem.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 11/11/2021
@return character, local de estocagem no cadastro da estação
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
