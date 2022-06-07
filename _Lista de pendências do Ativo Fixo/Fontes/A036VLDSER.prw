#INCLUDE "TOTVS.CH"
/*
Finalidade: Espec�fico para clientes que utilizam o Ponto de entrada do faturamento SX5NOTA.
Objetivo: Alterar a valida��o padr�o do campo FN6_SERIE na tela de baixa de ativos.
*/
User Function A036VLDSER()

	Local oModel := PARAMIXB[1]
	Local lRet   := .T.

	lRet := oModel:GetValue("FN6_GERANF") == '1' .And. EXISTCPO('SX5','01'+oModel:GetValue("FN6_SERIE"))

Return lRet
