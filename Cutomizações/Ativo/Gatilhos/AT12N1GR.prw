#include 'totvs.ch'
/*/{Protheus.doc} AT12N1GR
Função para ser utilizada no gatilho do campo N1_GRUPO para que depois da seleção do grupo o campo de 
Depreciação Acumulada seja populado com a conta cadastrada no campo correspondente no cadastro do grupo
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 11/05/2021
@return character, Código do Grupo selecionado
/*/
user function AT12N1GR()

	Local oModel     := FWModelActive()
	Local oView      := FWViewActive()
	Local oSN3Model  := oModel:GetModel('SN3DETAIL')
	Local cCtaDprAcm := AllTrim(SNG->NG_XCDAGER)
	Local nX         := 0

	for nX := 1 to oSN3Model:GetQTDLine()

		oSN3Model:nLine := nX

		if ! Empty( &(ReadVar()) ) .And. oSN3Model:GetValue('N3_TIPO') == '10'

			oSN3Model:SetValue('N3_CCDEPR',cCtaDprAcm)

		endIf

	next

	oSN3Model:nLine := 1

	oView:Refresh('SN3DETAIL')

return &(ReadVar())
