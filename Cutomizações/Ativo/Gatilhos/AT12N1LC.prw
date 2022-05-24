#include 'totvs.ch'
/*/{Protheus.doc} AT12N1LC
Função para ser utilizada no gatilho do campo N1_LOCAL para que depois da seleção do local os campos de 
Conta de Despesa de Depreciação dos valores do tipos 01 e 10 sejam populados com as contas cadastradas nos campos 
correspondentes no cadastro do local.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 11/05/2021
@return character, Código do Local selecionado
/*/
user function AT12N1LC()

	Local oModel     := FWModelActive()
	Local oView      := FWViewActive()
	Local oSN3Model  := oModel:GetModel('SN3DETAIL')
	Local cCtaDspDpC := AllTrim(SNL->NL_XDDCNT)
	Local cCtaDspDpG := AllTrim(SNL->NL_XDDGER)
	Local cCCusto    := AllTrim(SNL->NL_XCCUSTO)
	Local nX         := 0

	for nX := 1 to oSN3Model:GetQTDLine()

		oSN3Model:nLine := nX

		if ! Empty( &(ReadVar()) )

			if oSN3Model:GetValue('N3_TIPO') $ '01/03'

				oSN3Model:SetValue('N3_CDEPREC',cCtaDspDpC)

			elseIf oSN3Model:GetValue('N3_TIPO') == '10'

				oSN3Model:SetValue('N3_CDEPREC',cCtaDspDpG)

			endIf
			
			oSN3Model:SetValue('N3_CCUSTO',cCCusto)

		endIf


	next

	oSN3Model:nLine := 1

	oView:Refresh('SN3DETAIL')

return &(ReadVar())
