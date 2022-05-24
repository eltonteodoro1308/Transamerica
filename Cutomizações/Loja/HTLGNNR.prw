#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

static cTitulo := "Estações x Local de Estoque"

/*/{Protheus.doc} HTLGNNR
Função para o menu do sigaloja para vincular o cadastro da estação com o local de estoque
padrão através do campo LG_XLOCPAD esta rotina deve trabalhar em conjunto com o PE LJ7082.
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 06/10/2021
/*/
User Function HTLGNNR()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias("SLG")
	oBrowse:SetDescription( cTitulo )

	oBrowse:AddLegend( "EMPTY(LG_XLOCPAD)" , "RED"   , "Não vinculado a um local de estoque" )
	oBrowse:AddLegend( "!EMPTY(LG_XLOCPAD)", "GREEN" , "Vinculado a um local de estoque"     )

	oBrowse:SetMenuDef("HTLGNNR")

	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Monta o menu da rotina
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 06/10/2021
@return array, Array com as rotina do menu
/*/
Static Function MenuDef()

	Local aRotina  := {}
	Local cButtons := ''
	Local nX       := 0

	cButtons += '{'

	for nX := 1 to 15

		if nX ==  7

			cButtons += '{.T.,"Salvar"}'

		elseIf nX ==  8

			cButtons += '{.T.,"Cancelar"}'

		else

			cButtons += '{.F.,Nil}'

		endIf

		if nX < 15

			cButtons += ','

		endIf

	next 

	cButtons += '}'

	aAdd( aRotina, { 'Vincular' ,;
	"FWExecView( '" + cTitulo + "', 'HTLGNNR', " +;
     cValToChar(MODEL_OPERATION_UPDATE) +;
      ", nil, {||.T.}, {||.T.}, 0, " + cButtons + ", {||.T.}, '', '', nil)";
     , 0, 4, 0, NIL } )

Return aRotina

/*/{Protheus.doc} ModelDef
Monta o objeto com o modelo de dados
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 06/10/2021
@return object, Objeto do modelo de dados
/*/
Static Function ModelDef()

	Local oModel := MPFormModel():New("HTLGNNRM")
	Local oStruSLG := FwFormStruct( 1, "SLG", { | cpo | Alltrim( cpo )$ 'LG_CODIGO/LG_NOME/LG_XLOCPAD'} )

	oStruSLG:SetProperty( 'LG_XLOCPAD' , MODEL_FIELD_OBRIGAT, .T. )

	oModel:AddFields("SLGMASTER", NIL, oStruSLG)

	oModel:SetDescription( cTitulo )

	oModel:GetModel("SLGMASTER"):SetDescription( cTitulo )

Return oModel

/*/{Protheus.doc} ViewDef
Monta o objeto da view
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 06/10/2021
@return object, objeto da view
/*/
Static Function ViewDef()

	Local oView    := FwFormView():New()
	Local oStruSLG := FwFormStruct( 2, "SLG", { | cpo | Alltrim( cpo )$ 'LG_CODIGO/LG_NOME/LG_XLOCPAD'} )
	Local oModel   := FwLoadModel( "HTLGNNR" )

	oStruSLG:SetProperty( 'LG_CODIGO' , MVC_VIEW_CANCHANGE   , .F. )
	oStruSLG:SetProperty( 'LG_NOME'   , MVC_VIEW_CANCHANGE   , .F. )

	oView:SetModel( oModel )

	oView:AddField( "SLGVIEW", oStruSLG, "SLGMASTER")

	oView:CreateHorizontalBox("TELA" , 100)

	oView:SetOwnerView("SLGVIEW", "TELA")

Return oView
