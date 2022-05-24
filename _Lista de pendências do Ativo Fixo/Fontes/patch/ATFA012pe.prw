#include 'totvs.ch'
#Include 'fwmvcdef.ch'

/*/{Protheus.doc} ATFA012
Ponto de Entrada da rotina MVC ATFA012 - Cadastro de Ativo Fixo
Inclui no menu da rotina função que busca o próximo código e item de um bem original e um agregado.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 20/05/2022
@return variant, retorna array com rotina a ser definida no menu da rotina para o ponto de chamada BUTTONBAR e .T. para os demais. 
/*/
user function ATFA012()

	local xRet       := NIL
	local oObject    := PARAMIXB[ 1 ]
	local cIdPonto   := PARAMIXB[ 2 ]
	local cIdObject  := PARAMIXB[ 3 ]
	local aButtons   := {}

	cIdPonto := upper( allTrim( cIdPonto ) )

	if cIdPonto == 'BUTTONBAR'

		if ( oObject:nOperation == MODEL_OPERATION_INSERT .And. isInCallStack( 'ATFA012' )  ) .Or.;
				( oObject:nOperation == MODEL_OPERATION_UPDATE .And. isInCallStack( 'ATFA240' )  )

			aAdd( aButtons,  { 'Codificação Automática', '', {||U_SN1COD()}, 'Codificação Automática' } )

		end if

		xRet := aButtons

	else

		xRet := .T.

	end if

return xRet

/*/{Protheus.doc} SN1COD
Função que é adcionada no menu da tela de inclusão de cadastro de Ativo o próximo código e item de um bem original e um agregado.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 20/05/2022
/*/
user function SN1COD()

	Local cTitulo   := 'Codificação Automática'
	Local cText     := ''
	Local cMsg      := ''
	Local aBotoes   :=  { 'Bem Agregado', 'Cancelar', 'Bem Original' }
	local nRet      := 0
	local cCbase    := ''
	local cItem     := ''
	local aAreaSn1  := SN1->( getArea() )
	local oView     := FwViewActive()

	cMsg += 'Selecione a seguir que codificação deseja dar sequência.' + CRLF
	cMsg += 'Se a inclusão corresponde a um bem original ou ' + CRLF
	cMsg += 'a um bem agregado a outro bem já existente.' + CRLF

	nRet := Aviso ( cTitulo, cMsg, aBotoes, 3, cText )

	if nRet == aScan( aBotoes, 'Bem Agregado' )

		If ConPad1(, , , "SN1COD")

			cCbase := SN1->N1_CBASE
			cItem  := nextItem( cCbase )

		end if

		SN1->( restArea( aAreaSN1 ) )

	elseif nRet == aScan( aBotoes, 'Bem Original' )

		cCBase  := nextCBase()
		cItem  := '0000'

	elseif nRet == aScan( aBotoes, 'Cancelar' )

		// cancelar

	else

		// else

	endif

	if ! Empty( cCBase ) .And. ! Empty( cItem )

		FwFldPut( 'N1_CBASE', Space( TamSx3('N1_CBASE')[1] ) )
		FwFldPut( 'N1_ITEM', Space( TamSx3('N1_ITEM')[1] ) )

		oView:refresh('VIEW_SN1')

		FwFldPut( 'N1_CBASE', cCBase )
		FwFldPut( 'N1_ITEM', cItem )

		oView:refresh('VIEW_SN1')

	end if

return

/*/{Protheus.doc} nextItem
Busca o próximo código de um bem que já existe na base
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 20/05/2022
@param cCBase,charactere, Código do bem a ser verificado o próximo item
@return charactere, Próximo item do bem. 
/*/
static function nextItem( cCbase )

	local cAlias := getNextAlias()
	local cRet   := ''

	If Select(cAlias) <> 0

		(cAlias)->(DbCloseArea())

	EndIf

	BeginSql alias cAlias
      
        %NOPARSER%

        SELECT MAX(N1_ITEM) N1_ITEM FROM %TABLE:SN1%
        WHERE %NOTDEL%
        AND N1_FILIAL = %XFILIAL:SN1%
        AND N1_CBASE  = %EXP:cCbase%
		AND N1_STATUS = '1'
       
	EndSql

	If ( cAlias )->( !EOF() ) .And. ! Empty( ( cAlias )->N1_ITEM )

		cRet :=  PadR( Soma1( allTrim( ( cAlias )->N1_ITEM ) ), TamSx3( 'N1_ITEM' )[ 1 ] )

	else

		cRet := '0000'

	EndIf

	( cAlias )->( DbCloseArea() )

return cRet

/*/{Protheus.doc} nextCBase
Busca o próximo código de ativo disponível
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 20/05/2022
@return charactere, Próximo código base de ativo disponível
/*/
static function nextCBase()

	local cAlias := getNextAlias()
	local cRet   := ''

	If Select(cAlias) <> 0

		(cAlias)->(DbCloseArea())

	EndIf

	BeginSql alias cAlias
      
        %NOPARSER%

        SELECT MAX(N1_CBASE) N1_CBASE FROM %TABLE:SN1%
        WHERE %NOTDEL%
        AND N1_FILIAL = %XFILIAL:SN1%
		AND N1_STATUS = '1'
       
	EndSql

	If (cAlias)->( !EOF() ) .And. ! Empty(  (cAlias)->N1_CBASE )

		cRet :=  Soma1( allTrim( (cAlias)->N1_CBASE ) )

	else

		cRet :=  PadR( '000001', 6 )

	EndIf


	( cAlias )->( DbCloseArea() )

return cRet
