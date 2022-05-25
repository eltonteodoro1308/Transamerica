#Include 'totvs.ch'
/*/{Protheus.doc} AF251AHD
Ponto de entrada que permite manipular o aHeader da grid da tela de edição dos bens da rotina de Transferencia por Aquisição.
Foi implementado para permitir que o campo de localização seja exibido, pois não aparece por padrão.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 15/12/2021
@return array, aHeader ajustado com o campo de localização adicionado
/*/
User Function AF251AHD()

	local aHdAjustado := ParamIXB

	SX3->(DbSetOrder(2))
	
    If SX3->( DbSeek( "N1_LOCAL" ) )
	
    	aAdd( aHdAjustado, {;
		X3Titulo(),;
		SX3->X3_CAMPO,;
		AllTrim( SX3->X3_PICTURE ),;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		"", "",;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO } )
	
    endIf

Return aHdAjustado 
