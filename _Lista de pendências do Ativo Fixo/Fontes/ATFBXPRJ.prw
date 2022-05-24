#include 'totvs.ch'

user function AtfBxPrj()

	local cProjeto   := ''
	local cAlias     := getNextAlias()
	local aRecnos    := {}
	local nX         := 0
	local NHdlPrv    := 0
	local cArquivo   := ''
	local cLote      := AllTrim( Posicione( 'SX5', 1, xFilial( 'SX5' ) + '09ATF' , 'X5_DESCRI' ) )
	local cLctoPadr  := ''
	local cPrograma  := 'ATFBXPRJ'
	local lMostraLct := .F.
	local lAglutLct  := .F.
	local lCancBaixa := .F.

	if Pergunte( 'ATFBXPRJ', .T.)

		cProjeto   := MV_PAR01
		lMostraLct := MV_PAR02 == 1
		lAglutLct  := MV_PAR03 == 1
		lCancBaixa := MV_PAR04 == 1

		If Select(cAlias) <> 0

			(cAlias)->(DbCloseArea())

		EndIf

		if lCancBaixa .And.;
				ApMsgYesNo( 'Este procedimento bloqueia novamente a depreciação dos bens vinculados a este projeto'+;
				' e contabiliza o estorno da baixa do projeto, se houve depreciação processada o descalculo deverá ser executado, '+;
				' deseja prosseguir ?', 'Atenção' )

			cLctoPadr  := '8ZX'

			BeginSql alias cAlias

                SELECT SN3.R_E_C_N_O_ FROM %TABLE:SN3% SN3

                INNER JOIN %TABLE:SN1% SN1
                ON  SN1.D_E_L_E_T_ = SN3.D_E_L_E_T_
                AND SN1.N1_FILIAL  = SN3.N3_FILIAL
                AND SN1.N1_CBASE  = SN3.N3_CBASE
                AND SN1.N1_ITEM   = SN3.N3_ITEM
                
                WHERE SN3.%NOTDEL%
				AND   SN3.N3_FILIAL = %XFILIAL:SN3%
                AND   SN3.N3_CLVLCON = %EXP:cProjeto%
                AND   SN1.N1_DTBLOQ  <> %EXP:Space( TamSx3( 'N1_DTBLOQ' )[ 1 ] )% 
		
			EndSql

		else

			cLctoPadr  := '8ZZ'

			BeginSql alias cAlias

                SELECT SN3.R_E_C_N_O_ FROM %TABLE:SN3% SN3

                INNER JOIN %TABLE:SN1% SN1
                ON  SN1.D_E_L_E_T_ = SN3.D_E_L_E_T_
                AND SN1.N1_FILIAL  = SN3.N3_FILIAL
                AND SN1.N1_CBASE  = SN3.N3_CBASE
                AND SN1.N1_ITEM   = SN3.N3_ITEM
                
                WHERE SN3.%NOTDEL%
				AND   SN3.N3_FILIAL = %XFILIAL:SN3%
                AND   SN3.N3_CLVLCON = %EXP:cProjeto%
                AND   SN1.N1_DTBLOQ  = %EXP:Space( TamSx3( 'N1_DTBLOQ' )[ 1 ] )% 
		
			EndSql

		endIf

		( cAlias )->( DbGoTop() )

		if  ( cAlias )->( EOF() )

			ApMsgInfo( 'Não há registros a serem processados, verifique se os parâmetros estão corretos.', 'Atenção' )

			return

		endIf

		while ( cAlias )->( ! EOF() )

			( cAlias )->( aAdd( aRecnos, R_E_C_N_O_ ) )

			( cAlias )->( DbSkip() )

		end

		( cAlias )->( DbCloseArea() )

		DbSelectArea( 'SN3' )
		SN3->( DbSetOrder( 1 ) )

		DbSelectArea( 'SN1' )
		SN1->( DbSetOrder( 1 ) )

		nHdlPrv:= HeadProva( cLote, cPrograma, Alltrim( cUserName ), @cArquivo )

		for nX := 1 to Len( aRecnos )

			SN3->( DbGoTo( aRecnos[ nX ] ) )

			SN1->( DbSeek( SN3->( N3_FILIAL + N3_CBASE + N3_ITEM ) ) )

			DetProva( nHdlPrv, cLctoPadr, cPrograma, cLote )

			RecLock( 'SN1', .F. )

			if lCancBaixa

				SN1->N1_DTBLOQ := ctod('')

			else

				SN1->N1_DTBLOQ := stod('99991231')

			endIf

			SN1->( MsUnlock() )

		next nX

		RodaProva( nHdlPrv )

		cA100Incl( cArquivo, nHdlPrv, 3, cLote, lMostraLct, lAglutLct )

	end if

return
