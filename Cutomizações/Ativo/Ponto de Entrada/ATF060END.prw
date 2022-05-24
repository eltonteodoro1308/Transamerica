#Include 'Totvs.ch'
/*/{Protheus.doc} ATF060END
Ponto de entrada executado no final da gravação da transferência de grupos de bens para gravar as contas de 
despesa com depreciação e depreciação acumulada gerenciais dos campos correspondentes no cadastro do grupo do bem.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 11/05/2021
/*/
user function ATF060END()

	local aArea      := GetArea()
	Local aAreaSNL   := SNL->( GetArea() )
	Local aAreaSNG   := SNG->( GetArea() )
	Local aAreaSN3   := SN3->( GetArea() )
	Local aAreaFN9   := FN9->( GetArea() )
	Local aAreaFNR   := FNR->( GetArea() )
	Local aAreaFNS   := FNS->( GetArea() )
	Local cIdMov     := FN9->FN9_IDMOV
	Local cSeek      := xFilial('FNR') + cIdMov
	Local cGrpOrig   := ''
	Local cGrpDest   := ''
	Local cLocOrig   := ''
	Local cLocDest   := ''
	Local cCodRel    := ''
	Local cCbase     := ''
	Local cItem      := ''

	// Posiciona no topo da tabela de Ativos Transferidos
	FNR->( DbGoTop() )

	// // Posiciona no primeiro registro de Ativos Transferidos da Movimentação
	if FNR->( DbSeek( cSeek ) )

		while FNR->( ! Eof() .And. FNR_FILIAL + FNR_IDMOV == cSeek )

			cGrpOrig   := FNR->FNR_GRPORI // Grupo Origem
			cGrpDest   := FNR->FNR_GRPDES // Grupo Destino
			cLocOrig   := FNR->FNR_LOCORI // Local Origem
			cLocDest   := FNR->FNR_LOCDES // Local Destino
			cCodRel    := FNR->FNR_CODREL // Código do Relacionamento da movimentação
			cCbase     := FNR->FNR_CBAORI // Código do Bem
			cItem      := FNR->FNR_ITEORI // Item do Bem

			// Verifica se na transferência houve a mudança do Grupo de Bens
			if ( ! Empty( cGrpDest ) .And. cGrpOrig != cGrpDest )

				CtaDprAcum( cGrpDest, cIdMov, cCodRel, cCbase, cItem )

			endIf

			// Verifica se na transferência houve a mudança do Local de Bens
			if( ! Empty( cLocDest ) .And. cLocOrig != cLocDest )

				CtaDspDepr( cLocDest, cIdMov, cCodRel, cCbase, cItem )

			endIf

			FNR->( DbSkip() )

		enddo

	endif

	// Reposiciona as tabelas nos registros iniciais
	SNL->( RestArea( aAreaSNL ) )
	SNG->( RestArea( aAreaSNG ) )
	SN3->( RestArea( aAreaSN3 ) )
	FN9->( RestArea( aAreaFN9 ) )
	FNR->( RestArea( aAreaFNR ) )
	FNS->( RestArea( aAreaFNS ) )
	RestArea( aArea )

return

/*/{Protheus.doc} CtaDspDepr
Aplica ao bem as contas de despesa com depreciação do local do bem
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 01/07/2021
@param cLocDest, character, Código do local destino
@param cIdMov, character, Id da Movimentação
@param cCodRel, character, Código do Relacionamento da movimentação
@param cCbase, character, Código do Bem
@param cItem, character, Item do bem
/*/
static function CtaDspDepr( cLocDest, cIdMov, cCodRel, cCbase, cItem )

	Local cCtDspDprC := ''
	Local cCtDspDprG := ''
	Local cCCusto    := ''

	// Posiciona no Grupo de Bens destino
	if SNL->( DbSeek( xFilial() + cLocDest ) )

		// Salva em variável as contas "Despesa com Depreciação" Contábil/Gerencial e Fiscal
		cCtDspDprC := SNL->NL_XDDCNT
		cCtDspDprG := SNL->NL_XDDGER
		cCCusto    := SNL->NL_XCCUSTO

		// Posiciona no registro de saldo transferido do tipo 01 -> Fiscal se o mesmo existir
		if FNS->( DbSeek( xFilial() + cIdMov + cCodRel + '01' ) )

			// Existindo atualiza as contas gerenciais de "Despesa de Depreciação" e "Depreciação Acumulada"
			RecLock( 'FNS', .F. )

			FNS->FNS_CONDDD := cCtDspDprC
			FNS->FNS_CCDDD  := cCCusto

			FNS->( MsUnlock() )

			// Posiciona no registro de saldo do bem do tipo 01 -> Fiscal se o mesmo existir
			if SN3->( DbSeek( xFilial() + cCbase + cItem + '01' ) )

				RecLock( 'SN3', .F. )

				SN3->N3_CDEPREC := cCtDspDprC
				SN3->N3_CCUSTO  := cCCusto

				SN3->( MsUnlock() )

			endif

		endIf

		// Posiciona no registro de saldo transferido do tipo 10 -> Contábil/Gerencial se o mesmo existir
		if FNS->( DbSeek( xFilial() + cIdMov + cCodRel + '10' ) )

			// Existindo atualiza as contas gerenciais de "Despesa de Depreciação" e "Depreciação Acumulada"
			RecLock( 'FNS', .F. )

			FNS->FNS_CONDDD := cCtDspDprG
			FNS->FNS_CCDDD  := cCCusto

			FNS->( MsUnlock() )

			// Posiciona no registro de saldo do bem do tipo 10 -> Contábil/Gerencial se o mesmo existir
			if SN3->( DbSeek( xFilial() + cCbase + cItem + '10' ) )

				RecLock( 'SN3', .F. )

				SN3->N3_CDEPREC := cCtDspDprG
				SN3->N3_CCUSTO  := cCCusto

				SN3->( MsUnlock() )

			endif

		endIf

	endIf

return

/*/{Protheus.doc} CtaDprAcum
Aplica a conta de depreciação acumulada do grupo de bem
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 01/07/2021
@param cGrpDest, character, Grupo Destino
@param cIdMov, character, Id da Movimentação
@param cCodRel, character, Código do Relacionamento da movimentação
@param cCbase, character, Código do Bem
@param cItem, character, Item do bem
/*/
static function CtaDprAcum( cGrpDest, cIdMov, cCodRel, cCbase, cItem )

	Local cCtaDprAcm := ''

	// Posiciona no Grupo de Bens destino
	if SNG->( DbSeek( xFilial() + cGrpDest ) )

		// Salva em variável as contas gerenciais de "Depreciação Acumulada"
		cCtaDprAcm := SNG->NG_XCDAGER

		// Posiciona no registro de saldo transferido do tipo 10 -> Contábil/Gerencial se o mesmo existir
		if FNS->( DbSeek( xFilial() + cIdMov + cCodRel + '10' ) )

			// Existindo atualiza as contas gerenciais de "Despesa de Depreciação" e "Depreciação Acumulada"
			RecLock( 'FNS', .F. )

			FNS->FNS_CONDAD := cCtaDprAcm

			FNS->( MsUnlock() )

			// Posiciona no registro de saldo do bem do tipo 10 -> Contábil/Gerencial se o mesmo existir
			if SN3->( DbSeek( xFilial() + cCbase + cItem + '10' ) )

				RecLock( 'SN3', .F. )

				SN3->N3_CCDEPR  := cCtaDprAcm

				SN3->( MsUnlock() )

			endif

		endif

	endif

return
