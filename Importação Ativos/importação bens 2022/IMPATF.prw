#include 'totvs.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FileIO.ch"

/*
=====================================================================================
Programa............: IMPATF
Autor...............: Elton Zaniboni 
Data................: 16/01/2020
Descricao / Objetivo: Importação do Ativo Fixo via ExecAuto (SN1/SN3). FIS e GER.   
Solicitante.........: Janderson Monteiro
Uso.................: Catalent
Obs.................: Ajustar o parâmetro MV_ULTDEPR para 19000101 e desabilitar LPs
                      de inclusão manual ATF.
                      Criar C:\IMPORT\
=====================================================================================
*/

User Function IMPATF()

	Local aArea := GetArea()
	Local cItem := "1000"
	Local cDescri := "TESTE"
	Local nQtd := 1
	Local cChapa := "00000"
	Local cPatrim := "N"
	Local cGrupo := "109"
	Local dAquisic := dDataBase
	//Local dDtIniDepr := RetDinDepr(dDataBase)
	Local cDescric := "Teste 01"
	Local nQtd := 2
	Local cChapa := "00000"
	Local cPatrim := "N"
	Local cHistor := "TESTE "
	Local cContab := "1320203"
	Local cCusto := "3400"
	Local nValor := 1000
	Local nTaxa := 10
	Local nTamBase := TamSX3("N3_CBASE")[1]
	Local nTamChapa := TamSX3("N3_CBASE")[1]
	Local aParam := {}
	Local aCab := {}
	Local aItens := {}

	Local oDlg
	Local lPrim 	:= .T.
	Local aCampos 	:= {}
	Local aDados 	:= {}
	Local oDir  := nil
	Local oArq  := nil
	Local nOpca	:= 0

	Private cFile 		:= ""
	Private aVetor 		:= {}
	Private aBaixa		:= {}
	Private lMsErroAuto := .F.
	Private aErros := {}
	Private cDir  := "C:\IMPORT\"+Space(27)
	Private cArq  := Space(20)
	Private cArqTxt, nHdl
	Private nLinha
	Private cLinha 	:= ""

	DEFINE MSDIALOG oDlg TITLE "Carga de Dados: Importa tabela SN1/SN3 - ATIVO FIXO " FROM 010,000 TO 150,380 PIXEL	//130, 345 PIXEL
	@035,001 SAY "Diretório do Arquivo: " 	SIZE 055,007 OF oDlg PIXEL
	@035,070 MSGET oDir VAR cDir 	WHEN .T. SIZE 060,007 OF oDlg PIXEL
	@050,001 SAY "Nome do Arquivo: " 		SIZE 055,007 OF oDlg PIXEL
	@050,070 MSGET oArq VAR cArq 	WHEN .T. SIZE 060,007 OF oDlg PIXEL
	ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End() },{||nOpca:=2,oDlg:End() }) CENTERED

	If nOpca == 1
		//IncProc(" Aguarde Importando ATIVO FIXO "+cCBase+" ... ")
		IncProc(" Aguarde Importando ATIVO FIXO ... ")
		ImpSN1SN3()
	EndIf

Return()


Static Function ImpSN1SN3()

	Private cSeal	:= AllTrim(cDir)+AllTrim(cArq)
	Private nHdl    := fOpen(cSeal,400)

	cArqImp := RTRIM(cDir)+RTRIM(cArq)
//cArqImp := cFile
	If !File(cArqImp)
		MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importação será abortada!","[IMPATF] - ATENCAO")
		Return
	EndIf

	Processa( { |lEnd| Proc1() },"Incluindo ATIVO FIXO  ...." )
Return

Static Function Proc1
//nTamFile := fSeek(nHdl,0,2)
	fClose(nHdl)
	FT_FUSE(cSeal)
	FT_FGOTOP()
	cBuffer := FT_FREADLN()
	n       :=1
	nCont   := FT_FLASTREC()

	ProcRegua( nCont )

	nQtdImp := 0					//	contador de registros Importados.
	nQtdAlt := 0                    //	contador de registros Alterados.
	nQtdErr	:= 0					//	contador de registros com erro.
	nLinha	:= 0
	cLinha	:= ""
	nLidos  := 0
	_aCSV 	:= {}
	cHoraInicio := TIME()


	FT_FGOTOP()
	DO WHILE !FT_FEOF()
		nLinha++
		cLinha 	:= FT_FREADLN()
		Aadd(_aCSV , StrTokArr2(cLinha, ";",.t.))
		//If nLinha > 1 // Para nao ler o cabecalho
		fInclui() //Processa l
		//EndIf
		_aCSV 	:= {}
		IncProc("Processando...")
		nLidos ++
		FT_FSKIP()
	ENDDO
	FT_FUSE()

	cElapsed := ElapTime( cHoraInicio, TIME() )

	ApMsgInfo("Importados "+StrZero(nQtdImp,8)+" registros em "+cElapsed+" - tabela ATIVO FIXO!","[IMPATF] - SUCESSO")
	ApMsgInfo("Alterados  "+StrZero(nQtdAlt,8)+" registros em "+cElapsed+"  - tabela ATIVO FIXO!","[IMPATF] - SUCESSO")
	ApMsgInfo("Deram ERRO  "+StrZero(nQtdErr,8)+" registros em "+cElapsed+"  - tabela ATIVO FIXO!","[IMPATF] - SUCESSO")
Return


Static Function fInclui

	Local aAreaSN1 	:= SN1->(GetArea())
	Local aAreaSNG 	:= SNG->(GetArea())
	lError 		:= .F.

	If Len(_aCSV)> 0
		For I := 1 To Len(_aCSV)





//**********************************************************************************
// ATRIBUIÇÃO DOS CONTEÚDOS DOS CAMPOS DO ARQUIVO TXT EM VARIÁVEIS - CABEÇALHO - SN1
//**********************************************************************************


			cFilial     := xFilial("SN1") //Alltrim(_aCSV[1][2])                                         //N1_FILIAL
			cCBase		:= _aCSV[1][4]													//N1_CBASE
			cItem		:= _aCSV[1][5]													//N1_ITEM
			cGrupo  	:= Alltrim(_aCSV[1][2])									    	//N1_GRUPO
			cDescric	:= Alltrim(NoAcento(Upper(Substr(_aCSV[1][8],1,40))))		    //N1_DESCRIC
			cChapa		:= AllTrim(_aCSV[1][9])											//N1_CHAPA
			cPatrim		:= If(Empty(_aCSV[1][3]), "N", AllTrim(_aCSV[1][3]))			//N1_PATRIM
			nQuant		:= Val(_aCSV[1][7])										        //N1_QUANTD
			dDtAquis	:= CTOD(AllTrim(_aCSV[1][6]))       							//N1_AQUISIC
			cFornec		:= AllTrim(_aCSV[1][14])									    //N1_FORNEC
			cLojaFor	:= AllTrim(_aCSV[1][15])										//N1_LOJA
			cLocal		:= AllTrim(_aCSV[1][16])										//N1_LOCAL
			cNFiscal	:= AllTrim(_aCSV[1][17])										//N1_NFISCAL
			cCalcPis	:= AllTrim(_aCSV[1][18])									    //N1_CALCPIS**
			//cSerieNf	:= AllTrim(_aCSV[1][14])										//N1_NSERIE
			//cCodCiap    := AllTrim(_aCSV[1][15])										//N1_CODCIAP
			//cICMSApr	:= Val(_aCSV[1][16])										    //N1_ICMSAPR
			//cCodBemMNT:= AllTrim(_aCSV[1][17])								        //N1_CODBEM**
			//cStatus	:= If(Empty(_aCSV[1][18]), "1", AllTrim(_aCSV[1][18]))		    //N1_STATUS
			//cTpCtRat	:= _aCSV[1][19]												    //N1_TPCTRAT*
			cCodBar	    := AllTrim(_aCSV[1][19])									    //N1_CODBAR**
			cUtilbem	:= AllTrim(_aCSV[1][21])									    //N1_UTIPATR
			cOrigcrd	:= AllTrim(_aCSV[1][22])										//N1_ORIGCRD**
			cCstPis 	:= AllTrim(_aCSV[1][23])										//N1_CSTPIS**
			nAliqPis	:= Val(_aCSV[1][24])											//N1_ALIQPIS**
			//nAliqPis    := Val(StrTran(nAliqPis, ',' , '.' ))
			cCstCofi   	:= AllTrim(_aCSV[1][25])										//N1_CSTCOFI**
			nAliqCof    := Val(_aCSV[1][26])											//N1_ALIQCOF**
			//nAliqCof    := Val(StrTran(nAliqCof, ',' , '.' ))
			cCodBcc     := AllTrim(_aCSV[1][27])										//N1_CODBCC**
			cProduto	:= AllTrim(_aCSV[1][28])									    //N1_PRODUTO
			//cDetPatr	:= AllTrim(_aCSV[1][23])								        //N1_DETPATR
			//cCBcPis     := AllTrim(_aCSV[1][31])       								//N1_CBCPIS
			//cMescPis    := Val(_aCSV[1][32]) 		      								//N1_MESCPIS**
			cXmarca		:= AllTrim(_aCSV[1][29])									    //N1_XMARCA
			cXModelo	:= AllTrim(_aCSV[1][30])									    //N1_XMODELO
			cXSerie		:= AllTrim(_aCSV[1][31])									    //N1_XSERIE
			cXClVl		:= AllTrim(_aCSV[1][31])									    //N1_XSERIE
			cXDesClVl	:= AllTrim(_aCSV[1][31])									    //N1_XSERIE

//**********************************************************************************
// ATRIBUIÇÃO DOS CONTEÚDOS DOS CAMPOS DO ARQUIVO TXT EM VARIÁVEIS - FISCAL - SN3
//**********************************************************************************

			cTipoF  	:= If(Empty(_aCSV[1][41]), "01", AllTrim(_aCSV[1][41])) 		//N3_TIPO,C,2
			//cBaixa    : If(Empty(_aCSV[1][39]), "0", AllTrim(_aCSV[1][39]))           //N3_BAIXA,C,1
			cHistor 	:= Alltrim(NoAcento(Upper(Substr(_aCSV[1][42],1,40))))	       	//N3_HISTOR,C,40
			cTpSaldoF	:= "1"					      								    //N3_TPSALDO,C,1
			cTpDeprec	:= "1"													        //N3_TPDEPR,C,1
			dDtIniDepr  := CTOD(AllTrim(_aCSV[1][47]))          						//N3_DINDEPR,D**
			nVlrOrig1F	:= Val(_aCSV[1][48])       								            //N3_VORIG1,N,16,2
			//nVlrOrig1F	:= StrTran(Alltrim(nVlrOrig1F), '.' , '')                       //remove ponto
			//nVlrOrig1F 	:= Val(StrTran(nVlrOrig1F, ',' , '.' ))                         // troca virgula por ponto
			nTxDeprF	:= Val(_aCSV[1][49])										    //N3_TXDEPR1,N,9,4
			nVrDacm1    := Val(_aCSV[1][50])                                            //N3_VRDACM1,N,16,2
			//nVrDacm1    := StrTran(Alltrim(nVrDacm1), '.' , '')
			//nVrDacm1    := Val(StrTran(nVrDacm1, ',' , '.' ))
			dAquisic    := CTOD(AllTrim(_aCSV[1][51]))									//N3_AQUISIC,D
			//dDtBaixa	:= CTOD(AllTrim(_aCSV[1][53]))									//N3_DTBAIXA,D
			cDescEst	:= AllTrim(_aCSV[1][53])										//N3_DESCEST,M,80

			cClassVal   := AllTrim(_aCSV[1][32])                                        //N3_CLVLCON
			//cItemCt   := AllTrim(_aCSV[1][79])                                        //N3_CLVLCON

			cContaCta	:=  AllTrim(_aCSV[1][43])    //Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CCONTAB"))				    //N3_CCONTAB,C,20
			//cCustoBem	:= " " //Val(_aCSV[1][44])		       								//N3_CUSTBEM,C,9
			cCtDeprec	:= AllTrim(_aCSV[1][44])     //Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CDEPREC"))  								    //N3_CDEPREC,C,20
			cCCusto	    := AllTrim(_aCSV[1][45])		       								//N3_CCUSTO,C,9
			cCcDepr	    := AllTrim(_aCSV[1][46])       //Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CCDEPR"))                                     //N3_CCDEPR,C,20
			//cCCDesp    := Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CCDESP")) 	       								//N3_CCUSTO,C,9



//**********************************************************************************
// ATRIBUIÇÃO DOS CONTEÚDOS DOS CAMPOS DO ARQUIVO TXT EM VARIÁVEIS - GERENCIAL - SN3
//**********************************************************************************

			cTipoG	    := If(Empty(_aCSV[1][61]), "10", AllTrim(_aCSV[1][61]))			//N3_TIPO,C,2
			cHistorG 	:= Alltrim(NoAcento(Upper(Substr(_aCSV[1][62],1,40))))	       	//N3_HISTOR,C,40
			cTpSaldoG	:= "1"					      								    //N3_TPSALDO,C,1
			cTpDeprecG	:= "1"													        //N3_TPDEPR,C,1
			dDtIniDeprG  := CTOD(AllTrim(_aCSV[1][67]))          						//N3_DINDEPR,D**
			nVlrOrig1G	:= Val(_aCSV[1][68])       								            //N3_VORIG1,N,16,2
			//nVlrOrig1G	:= StrTran(Alltrim(nVlrOrig1G), '.' , '')                       //remove ponto
			//nVlrOrig1G 	:= Val(StrTran(nVlrOrig1G, ',' , '.' ))                         // troca virgula por ponto
			nTxDeprG	:= Val(_aCSV[1][69])										    //N3_TXDEPR1,N,9,4
			nVrDacm1G    := Val(_aCSV[1][70])                                            //N3_VRDACM1,N,16,2
			//nVrDacm1G  := StrTran(Alltrim(nVrDacm1G), '.' , '')
			//nVrDacm1G    := Val(StrTran(nVrDacm1G, ',' , '.' ))
			dAquisicG    := CTOD(AllTrim(_aCSV[1][71]))									//N3_AQUISIC,D
			//dDtBaixa	:= CTOD(AllTrim(_aCSV[1][53]))									//N3_DTBAIXA,D
			cDescEstG	:= AllTrim(_aCSV[1][73])										//N3_DESCEST,M,80
			cClassValG   := AllTrim(_aCSV[1][32])                                        //N3_CLVLCON
			//cItemCt   := AllTrim(_aCSV[1][79])                                        //N3_CLVLCON
			cContaCtaG	:=  AllTrim(_aCSV[1][63])    //Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CCONTAB"))				    //N3_CCONTAB,C,20
			//cCustoBem	:= " " //Val(_aCSV[1][44])		       								//N3_CUSTBEM,C,9
			cCtDeprecG	:= AllTrim(_aCSV[1][64])     //Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CDEPREC"))  								    //N3_CDEPREC,C,20
			cCCustoG	:= AllTrim(_aCSV[1][65])		       								//N3_CCUSTO,C,9
			cCcDeprG	    := AllTrim(_aCSV[1][66])       //Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CCDEPR"))                                     //N3_CCDEPR,C,20
			//cCCDesp    := Alltrim(Posicione("SNG",1,xFilial("SNG")+cGrupo,"NG_CCDESP")) 	       								//N3_CCUSTO,C,9




//*********************************************************************
//VALIDAÇÕES BÁSICAS DOS DADOS INFORMADOS NO ARQUIVO TXT.
//*********************************************************************

			If Empty(cCbase)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Código do Ativo: "+cCbase+" "+cItem+"  em branco: "+cCbase,.t.)
			EndIf

			If Empty(cItem)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Código do Item do Ativo : "+cCbase+" "+cItem+" em branco: "+cCbase,.t.)
			EndIf

			If Empty(cGrupo)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Grupo de Bens do Ativo : "+cCbase+" "+cItem+" não preenchida: "+cGrupo,.t.)
			EndIf

			If !ExistCpo("SNG",cGrupo)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Grupo de Bens do Ativo : "+cCbase+" "+cItem+" não existe: "+cGrupo,.t.)
			EndIf

			If Empty(cDescric)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Descrição do Ativo : "+cCbase+" "+cItem+" não preenchida: "+cDescric,.t.)
			EndIf

			If Empty(nQuant)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Quantidade do Ativo : "+cCbase+" "+cItem+" não preenchida ou inválida: "+nQuant,.t.)
			EndIf

			//If Empty(dDtAquis)
			//	lError := .T.
			//	nQtdErr++
			//	Aadd(aErros, "Data de Aquisição do Ativo : "+cCbase+" "+cItem+" não preenchida ou inválida: "+DToc(dDtAquis),.t.)
			//EndIf

			//If Empty(dDtIniDepr)
			//	lError := .T.
			//	nQtdErr++
			//	Aadd(aErros, "Data de Inicio de Depreciação do Ativo : "+cCbase+" "+cItem+" não preenchida ou inválida: "+Dtoc(dDtIniDepr),.t.)
			//EndIf


			//If !ExistCpo("SA2",cFornec)
			//    lError := .T.
			//    Aadd(aErros, "Fornecedor do Ativo : "+cCbase+" "+cItem+" não está cadastrado: "+cFornec,.t.)
			//EndIf

			If Empty(cHistor)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Histórico do Ativo : "+cCbase+" "+cItem+" não preenchida ou inválida: "+cHistor,.t.)
			EndIf

			//If Empty(nTxDeprF) .or. Empty(nTxDeprG)
			//    lError := .T.
			//    Aadd(aErros, "Taxa de Depreciação Fiscal/Gerencial do Ativo : "+cCbase+" "+cItem+" não preenchida: ",.t.)
			//EndIf

			//           If Empty(nVrDacm1) //.OR. !cGrupo $ "999/112/102" .OR. dDtIniDepr < '20191101'     //999 - Grupo de Imobilizado em Andamento. 112 - Ativo Intangível, e 102 - Terrenos.  Não tem depreciação Acumulada.
			//               lError := .T.
			//               Aadd(aErros, "Valor Depreciação Acumulada do Ativo : "+cCbase+" "+cItem+" não preenchida: ",.t.)
			//           EndIf

			//If nVrDacm1 > nVlrOrig1F
			//	lError := .T.
			//	nQtdErr++
			//	Aadd(aErros, "Valor Depreciação Acumulada é maior que o Valor do Bem. Ativo : "+cCbase+" "+cItem+" . ",.t.)
			//EndIf

/*            If Empty(cContaCta)
                lError := .T.
                Aadd(aErros, "Conta Contábil do Ativo : "+cCbase+" "+cItem+" não preenchida: ",.t.)
		EndIf

		If Empty(cCtDeprec)
                lError := .T.
                Aadd(aErros, "Conta Contábil Despesa Depreciação do Ativo : "+cCbase+" "+cItem+" não preenchida: ",.t.)
		EndIf
*/
			If Empty(nVlrOrig1F)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "Valor do Ativo : "+cCbase+" "+cItem+" não preenchido para Tipo Fiscal: ",.t.)
			EndIf




			/*
			If !ExistCpo("CTD",cItemCt)
				lError := .T.
				nQtdErr++
				Aadd(aErros, "item Contábil do Ativo : "+cCbase+" "+cItem+" não está cadastrada: "+cItemCt,.t.)
			EndIf
			*/

			// If (Empty(nVlrOrig1G) .or. nVlrOrig1G == 0) .AND. cGrupo <> "112"     //112 - Grupo de Marcar e Patentes.
			//     lError := .T.
			//     Aadd(aErros, "Valor do Ativo : "+cCbase+" "+cItem+" não preenchido para Tipo Gerencial. ",.t.)
			// EndIf


/*
		If !ExistCpo("CT1",cContaCta)
                lError := .T.
                Aadd(aErros, "Conta Contabil do Ativo : "+cCbase+" "+cItem+" não está cadastrada: "+cContaCta,.t.)
		EndIf

		If !ExistCpo("CT1",cCtDeprec)
                lError := .T.
                Aadd(aErros, "Conta Contábil Depr Acumulada do Ativo : "+cCbase+" "+cItem+" não está cadastrada: "+cCtDeprec,.t.)
		EndIf

		If !ExistCpo("CTT",CCustoBem) //.and. !Empty(CCustoBem)
                lError := .T.
                Aadd(aErros, "Centro de Custo do Ativo : "+cCbase+" "+cItem+" não está cadastrado: "+CCustoBem,.t.)
		EndIf

		If !ExistCpo("CTH",cClassVal) //.and. !Empty(cClassVal)
                lError := .T.
                Aadd(aErros, "Classe de Valor/Capex do Ativo : "+cCbase+" "+cItem+" não está cadastrada: "+cClassVal,.t.)
		EndIf
*/

			Private lMsErroAuto := .F.
			Private lMsHelpAuto := .T.

			If !lError

				aParam := {}
				aAdd( aParam, {"MV_PAR01", 2} ) //Pergunta 01 - Mostra Lanc.Contab ? 1 = Sim ; 2 = Não
				aAdd( aParam, {"MV_PAR02", 1} ) //Pergunta 02 - Repete Chapa ? 1 = Sim ; 2 = Não
				aAdd( aParam, {"MV_PAR03", 2} ) //Pergunta 03 - Descrição estendida? 1 = Sim ; 2 = Não
				aAdd( aParam, {"MV_PAR04", 2} ) //Pergunta 04 - Copiar Valores ? 1 = Todos ; 2 = Sem Acumulado


				aCab := {}
				AAdd(aCab,{"N1_FILIAL" , cFilial ,NIL})
				AAdd(aCab,{"N1_CBASE" , cCBase ,NIL})
				AAdd(aCab,{"N1_ITEM" , cItem ,NIL})
				AAdd(aCab,{"N1_GRUPO" , cGrupo ,NIL})
				AAdd(aCab,{"N1_DESCRIC", cDescric ,NIL})
				AAdd(aCab,{"N1_CHAPA" , cChapa ,NIL})
				AAdd(aCab,{"N1_PATRIM" , cPatrim ,NIL})
				AAdd(aCab,{"N1_QUANTD" , nQuant ,NIL})
				AAdd(aCab,{"N1_AQUISIC", dDtAquis ,NIL})
				AAdd(aCab,{"N1_FORNEC", cFornec ,NIL})
				AAdd(aCab,{"N1_LOJA", cLojaFor ,NIL})
				AAdd(aCab,{"N1_LOCAL", cLocal ,NIL})
				AAdd(aCab,{"N1_NFISCAL", cNFiscal ,NIL})
				//AAdd(aCab,{"N1_CALCPIS", cCalcPis ,NIL})
				AAdd(aCab,{"N1_CODBAR", cCodBar ,NIL})
				AAdd(aCab,{"N1_UTIPATR", cUtilbem ,NIL})
				AAdd(aCab,{"N1_ORIGCRD", cOrigcrd ,NIL})
				AAdd(aCab,{"N1_CSTPIS", cCstPis ,NIL})
				AAdd(aCab,{"N1_ALIQPIS", nAliqPis ,NIL})
				AAdd(aCab,{"N1_CSTCOFI", cCstCofi ,NIL})
				AAdd(aCab,{"N1_ALIQCOF", nAliqCof ,NIL})
				AAdd(aCab,{"N1_CODBCC", cCodBcc ,NIL})
				AAdd(aCab,{"N1_PRODUTO", cProduto ,NIL})
				AAdd(aCab,{"N1_XMARCA", cXmarca ,NIL})
				AAdd(aCab,{"N1_XMODELO", cXModelo ,NIL})
				AAdd(aCab,{"N1_XSERIE", cXSerie ,NIL})
				//AAdd(aCab,{"", cXClVl ,NIL})
				//AAdd(aCab,{"", cXDesClVl ,NIL})

				//==============================================
				//  DEPRECIAÇÃO FISCAL = N3_TIPO = '01'
				//==============================================
				aItens := {}
				aAdd(aItens,{ {"N3_FILIAL",xFilial("SN3"),NIL},;
					{"N3_TIPO   " ,"01",NIL},;
					{"N3_HISTOR " ,Substr(cHistor,1,40),NIL},;
					{"N3_TPSALDO" ,cTpSaldoF,NIL},;
					{"N3_TPDEPR" ,cTpDeprec,NIL},;
					{"N3_DINDEPR" ,dDtIniDepr,NIL},;
					{"N3_VORIG1 " ,nVlrOrig1F,NIL},;
					{"N3_VORIG2 " ,0, NIL},;
					{"N3_VORIG3 " ,0, NIL},;
					{"N3_TXDEPR1" ,nTxDeprF,NIL},;
					{"N3_VRDACM1" ,nVrDacm1,NIL},;
					{"N3_AQUISIC" ,dDtAquis,NIL},;
					{"N3_CCONTAB" ,cContaCta,NIL},;
					{"N3_CCDEPR " ,cCcDepr,NIL},;
					{"N3_CDEPREC" ,cCtDeprec,NIL},;
					{"N3_CCUSTO " ,cCCusto,NIL},;
					{"N3_SEQ" 	  ,"001",NIL},;
					{"N3_CLVLCON" ,cClassVal ,NIL},;
					{"N3_DESCEST" ,cDescEst,NIL}})//,;

				//==============================================
				//  DEPRECIAÇÃO GERENCIAL = N3_TIPO = '10'
				//==============================================
				aAdd(aItens,{ {"N3_FILIAL",xFilial("SN3"),NIL},;
					{"N3_TIPO   " ,"10",NIL},;
					{"N3_HISTOR " ,Substr(cHistorG,1,40),NIL},;
					{"N3_TPSALDO" ,cTpSaldoG,NIL},;
					{"N3_TPDEPR" ,cTpDeprecG,NIL},;
					{"N3_DINDEPR" ,dDtIniDeprG,NIL},;
					{"N3_VORIG1 " ,nVlrOrig1G,NIL},;
					{"N3_VORIG2 " ,0, NIL},;
					{"N3_VORIG3 " ,0, NIL},;
					{"N3_TXDEPR1" ,nTxDeprG,NIL},;
					{"N3_VRDACM1" ,nVrDacm1G,NIL},;
					{"N3_AQUISIC" ,dDtAquis,NIL},;
					{"N3_CCONTAB" ,cContaCtaG,NIL},;
					{"N3_CCDEPR " ,cCcDeprG,NIL},;
					{"N3_CDEPREC" ,cCtDeprecG,NIL},;
					{"N3_CCUSTO " ,cCCustoG,NIL},;
					{"N3_SEQ" 	  ,"002",NIL},;
					{"N3_CLVLCON" ,cClassValG ,NIL},;
					{"N3_DESCEST" ,cDescEstG,NIL}})


				//==============================================
				//  DEPRECIAÇÃO FISCAL = N3_TIPO = '16'
				//==============================================

				//==============================================
				//  DEPRECIAÇÃO FISCAL = N3_TIPO = '17'
				//==============================================

				//==============================================
				//  DEPRECIAÇÃO FISCAL = N3_TIPO = '16'
				//==============================================



				dbSelectArea("SN1")
				dbSetOrder(1)
				If !dbSeek(xFilial("SN1") + cCBase + cItem  )

					ATF012EXE( 'I' )
				Else

					lError := .T.
					Aadd(aErros, "O Ativo Fixo: "+cCBase+" "+cItem+" já existe na base de dados.",.t.)


					ATF012EXE( 'A' )

				EndIf

			EndIf
		Next
	Else
		MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importação será abortada!","[IMPATF] - ATENCAO")
		Return
	EndIf

	If Len(aErros) > 0
		Resumo()
		aErros := {}
	EndIf

Return





Static Function Resumo

	Local cCRLF := CHR(13)+CHR(10)

	cDir 	:= "C:\IMPORT\"
	cArqTxt := cDir+"IMPATF_ERROS_IMP_ATIVO_"+cFilial+".CSV"

	If ! FILE ( cArqTxt )
		nHdl    := fCreate(cArqTxt,0)
		If  nHdl >= 0
			fclose(nHdl)
		EndIf
	EndIf

	// Abre o arquivo
	nHandle := fopen(cArqTxt , FO_READWRITE + FO_SHARED )
	If nHandle == -1
		//MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
	Else
		FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo

		// FWrite(nHandle, "Nova Linha", 10) // Insere texto no arquivo
		//FWrite(nHandle, "Status") // Insere texto no arquivo

		If Len( aErros ) > 0
			For nY := 1 TO LEN(aErros)
				cLinErr	:= aErros[nY]
				cRet 	:= StrZero(nY,4)+" - "+cLinErr + cCRLF

				FWrite(nHandle , cRet )
			NEXT
		EndIf

		Fclose(nHandle)                   // Fecha arquivo

	Endif

Return Nil







Static FUNCTION ATF012EXE( cMov )

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	//Begin Transaction

	If cMov == 'I'
		MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	Else
		cMov == 'A'
		//MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	Endif

	If lMsErroAuto
		MostraErro()
		//DisarmTransaction()
	Else
		If cMov == 'I'
			nQtdImp++
		ElseIf cMov == 'A'
			nQtdAlt++
		EndIf


		//RestArea(aArea)

	EndIf

	//End Transaction

Return
