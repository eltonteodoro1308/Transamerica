#include 'totvs.ch'
/*/{Protheus.doc} LJ7041
Ponto de entrdada que permite personalização do almoxarifado onde o saldo é consultado, 
buscando no campo LG_XLOCPAD do cadastro de estação o local onde deve ser baixado o produto da venda.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 24/11/2021
@return character, Código do local de estoque
/*/
user function LJ7041()

	Local cLocal    := ParamIxb[1] // Recebe parâmetro contendo almoxarifado
	Local aColsDet  := ParamIxb[2] // Recebe parâmetro contendo o array aColsDet
	Local cLocalPdv := locEst()

	if !Empty( cLocalPdv )

		return cLocalPdv

	endIf

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
