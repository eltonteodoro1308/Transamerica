#include 'totvs.ch'
/*/{Protheus.doc} LJ7041
Ponto de entrdada que permite personaliza��o do almoxarifado onde o saldo � consultado, 
buscando no campo LG_XLOCPAD do cadastro de esta��o o local onde deve ser baixado o produto da venda.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 24/11/2021
@return character, C�digo do local de estoque
/*/
user function LJ7041()

	Local cLocal    := ParamIxb[1] // Recebe par�metro contendo almoxarifado
	Local aColsDet  := ParamIxb[2] // Recebe par�metro contendo o array aColsDet
	Local cLocalPdv := locEst()

	if !Empty( cLocalPdv )

		return cLocalPdv

	endIf

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
