#include 'totvs.ch'
#include 'dwconst.ch'

/*/{Protheus.doc} NFSEUNA
Programa que trata da geração do arquivo de NFS-e para prefeitura de UNA-BA,
a importação do arquvo de retorno e o relatório de controle
@type function
@version 12.1.27  
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
user function NFSEUNA()

	Local aButton := {'Imprimir Controle','Gerar TXT','Importar TXT','Sair'}
	Local nAviso  := 0
	Local cCodFil := FWPesqSM0("M0_CODFIL")

	if Empty( cCodFil )

		return

	else

		cFilAnt := cCodFil
		cNumEmp := cEmpAnt + cFilAnt

		SM0->( DbSetOrder( 1 ) )
		SM0->( DbSeek( cNumEmp ) )

	endIf

	nAviso := Aviso ( 'NFSEUNA',;
		'Programa que trata da geração do arquivo de NFS-e para prefeitura de UNA-BA, '+;
		'a importação do arquvo de retorno e o relatório de controle.',;
		aButton, 2, 'Nota Fiscal de Serviços Una-BA' )


	if nAviso == aScan( aButton, 'Gerar TXT' )

		GeraTxt()

	elseif nAviso == aScan( aButton, 'Importar TXT' )

		ImportaTxt()

	elseif nAviso == aScan( aButton, 'Imprimir Controle' )

		ImpControl()

	else

	endif

return

/*/{Protheus.doc} GeraTxt
Função que gerar o arquivo texto de exportação para prefeitura de UNA-BA
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function GeraTxt()

	Private cTrab       := GetNextAlias()
	Private nSequencial := 1
	Private nTotalNFs   := 0

	if pergunte('NFSEUNAEXP')

		if ExistDir( MV_PAR07 )

			Alert( 'A pasta informada não é válida !!!' )

		else

			// Executa o preenchimento do campo FT_CODNFE com numeração sequencial
			MsgRun( 'Gerando numeração sequencial ...', 'Aguarde ...', PrcNumSeq() )

			// Faz a consulta e cria a tabela com os dados de exportação
			MsgRun( 'Processando Consulta ...', 'Aguarde ...', PrcTrabExp() )

			// Verifica se a consulta retornou vazia
			If ( cTrab )->( Eof() )

				Alert( 'Não há Notas a serem geradas !!!' )

			else

				ProcTxt()

				// Fecha a tabela de consulta
				if Select( cTrab ) <> 0

					( cTrab )->( DbCloseArea() )

				endif

			endif

		endif

	endif

return

/*/{Protheus.doc} PrcNumSeq
Executa o preenchimento do campo FT_CODNFE com numeração sequencial
numeração sequencial gerada automaticamente baseda na data/hora/minuto/segundo
@type function
@version 12.1.27 
@author elton.alves
@since 25/05/2021
/*/
static function PrcNumSeq()

	Local cTabTemp := GetNextAlias()
	Local cNextSeq := DTOS(DATE())+STRTRAN(TIME(),':','')+StrZero(Int(Seconds()),6)
	Local aRecno   := {}
	Local nX       := 0
	Local nY       := 0
	Local nPos     := 0

	// Se selecionado apenas notas canceladas não gera sequencial nenhum
	if MV_PAR13 == 3

		return

	endIf

	BeginSql alias cTabTemp

	%NOPARSER%

		SELECT SF3.R_E_C_N_O_ F3_RECNO, SFT.R_E_C_N_O_ FT_RECNO 
		
		FROM %TABLE:SF3% SF3

		LEFT JOIN %TABLE:SFT% SFT
		ON SF3.F3_FILIAL = SFT.FT_FILIAL
		AND SF3.F3_EMISSAO = SFT.FT_EMISSAO
		AND SF3.F3_SERIE = SFT.FT_SERIE
		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL
		AND SF3.F3_DTCANC = SFT.FT_DTCANC
		
		WHERE SF3.%NOTDEL%
		AND SFT.%NOTDEL%
		AND SF3.F3_FILIAL = %XFILIAL:SF3%
		AND SFT.FT_FILIAL = %XFILIAL:SFT%
		AND SFT.FT_TIPOMOV = 'S'
		AND SF3.F3_TIPO = 'S' 
		AND SF3.F3_SERIE BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
		AND SF3.F3_NFISCAL BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
		AND SF3.F3_EMISSAO BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
		AND SF3.F3_CLIEFOR BETWEEN %EXP:MV_PAR07% AND %EXP:MV_PAR09%
		AND SF3.F3_LOJA BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR10%
		AND SF3.F3_CODNFE = ''
		AND LEN(SF3.F3_DTCANC) = 0
	
	EndSql

	( cTabTemp )->( DbGoTop() )

	while ( cTabTemp )->( ! Eof() )

		nPos := aScan( aRecno, { |item| item[1] == ( cTabTemp )->F3_RECNO } )

		if nPos == 0

			( cTabTemp )->( aAdd( aRecno, { F3_RECNO, { FT_RECNO } }  ) )

		else

			( cTabTemp )->( aAdd( aRecno[ nPos, 2 ], FT_RECNO ) )

		endIf

		( cTabTemp )->( DbSkip() )

	enddo

	( cTabTemp )->( DbCloseArea() )

	DbSelectArea( 'SF3' )
	DbSelectArea( 'SFT' )

	for nX := 1 to Len( aRecno )

		SF3->( DbGoTo( aRecno[ nX, 1 ] ) )

		if aRecno[ nX, 1 ] == SF3->( Recno() )

			RecLock( 'SF3', .F. )

			SF3->F3_CODNFE := cNextSeq

			SF3->( MsUnlock() )

		endif

		for nY := 1 To Len( aRecno[ nX, 2 ] )

			SFT->( DbGoTo( aRecno[ nX, 2, nY ] ) )

			if aRecno[ nX, 2, nY ] == SFT->( Recno() )

				RecLock( 'SFT', .F. )

				SFT->FT_CODNFE := cNextSeq

				SFT->( MsUnlock() )

			endif

		next

		cNextSeq := cValtoChar( Val( cNextSeq ) + 1 )
		cNextSeq := PadL( cNextSeq, 20, "0" )

	next

return

/*/{Protheus.doc} PrcTrabExp
Função que efetua a pesquisa no banco dos dados necessários para gerar o arquivo Texto e
popula variável privada com a quantidade de notas localizadas.
@type function
@version  12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function PrcTrabExp()

	local aSeq    := {}
	local cWhere1 := ''
	local cWhere2 := 'NF CANCELADA'


	if MV_PAR13 == 2 // Apenas Não Canceladas

		cWhere2 := ''

	ElseIf MV_PAR13 == 3 // Apenas Canceladas

		cWhere1 := 'NF CANCELADA'

	endIf

	BeginSql Alias cTrab

		SELECT
		SEQUENCIAL_NFSE = SF3.F3_CODNFE,
		DATA_HORA_NFSE = SF3.F3_EMISSAO + '000000',
		SITUACAO_NFSE = CASE WHEN LEN(SF3.F3_DTCANC) = 0 THEN 'T' ELSE 'C' END,
		DATA_CANCELAMENTO_NFSE = SF3.F3_DTCANC,
		TOTAL_SERVICOS =  CASE WHEN LEN(SF3.F3_DTCANC) = 0 THEN SF3.F3_VALCONT ELSE 0 END,
		TOTAL_ISSQN = CASE WHEN LEN(SF3.F3_DTCANC) = 0 THEN SF3.F3_VALICM ELSE 0 END,

		QUANTIDADE = SFT.FT_QUANT,
		VALOR_SERVICO = CASE WHEN LEN(SFT.FT_DTCANC) = 0 THEN SFT.FT_VALCONT ELSE 0 END,
		ALIQUOTA_ISS = SFT.FT_ALIQICM,
	
		INDICADOR_CPF_CNPJ = CASE WHEN SA1.A1_EST = 'EX' THEN '9' WHEN SA1.A1_PESSOA = 'F' THEN '1' WHEN SA1.A1_PESSOA = 'J' THEN '2' ELSE '3' END,
		TOMADOR_DOCUMENTO = CASE WHEN SA1.A1_EST = 'EX' THEN SA1.A1_PFISICA ELSE SA1.A1_CGC END,
		NOME_TOMADOR = SA1.A1_NOME,
		NOME_FANTASIA = SA1.A1_NREDUZ,
		TOMADOR_ENDERECO = SA1.A1_END,
		COMPLEMENTO_TOMADOR = SA1.A1_COMPLEM,
		BAIRRO_TOMADOR = SA1.A1_BAIRRO,
		CIDADE_TOMADOR = SA1.A1_MUN,
		UF_TOMADOR = SA1.A1_EST,
		CEP_TOMADOR = SA1.A1_CEP,
		EMAIL_TOMADOR = SA1.A1_EMAIL,
		IE_TOMADOR = SA1.A1_INSCR,
		INSCR_MUNIC_TOM = SA1.A1_INSCRM,

		COD_LC_PRD = ( SELECT TOP 1 CDN.CDN_CODLST FROM %TABLE:CDN% CDN 
						WHERE CDN.%NOTDEL%
						AND CDN.CDN_FILIAL = %XFIlIAL:CDN%
						AND CDN.CDN_CODISS = SBZ.BZ_CODISS
						AND CDN.CDN_PROD = SB1.B1_COD ),

		COD_LC = ( SELECT TOP 1 CDN2.CDN_CODLST FROM %TABLE:CDN% CDN2
					WHERE CDN2.%NOTDEL%
					AND CDN2.CDN_FILIAL = %XFILIAL:CDN%
					AND CDN2.CDN_CODISS = SBZ.BZ_CODISS
					AND LEN(CDN2.CDN_PROD) = 0 ),

		UNIDADE = SB1.B1_UM,
		DESCRICAO_SERVICO = SB1.B1_DESC,
		COD_TRIB_MUNICIPIO = SBZ.BZ_CODISS

		FROM %TABLE:SF3% SF3

		LEFT JOIN %TABLE:SFT% SFT
		ON SF3.F3_FILIAL = SFT.FT_FILIAL
		AND SF3.F3_EMISSAO = SFT.FT_EMISSAO
		AND SF3.F3_SERIE = SFT.FT_SERIE
		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL
		AND SF3.F3_DTCANC = SFT.FT_DTCANC		

		LEFT JOIN %TABLE:SA1% SA1
		ON SF3.F3_CLIEFOR = SA1.A1_COD
		AND SF3.F3_LOJA = SA1.A1_LOJA

		LEFT JOIN %TABLE:SB1% SB1
		ON SFT.FT_PRODUTO = SB1.B1_COD

		LEFT JOIN %TABLE:SBZ% SBZ
		ON SBZ.BZ_COD = SB1.B1_COD

		WHERE SF3.%NOTDEL%
		AND SFT.%NOTDEL%
		AND SA1.%NOTDEL%
		AND SB1.%NOTDEL%
		AND SBZ.%NOTDEL%
		AND SF3.F3_FILIAL = %XFILIAL:SF3%
		AND SFT.FT_FILIAL = %XFILIAL:SFT%
		AND SA1.A1_FILIAL = %XFILIAL:SA1%
		AND SB1.B1_FILIAL = %XFILIAL:SB1%
		AND SBZ.BZ_FILIAL = %XFILIAL:SBZ%
		AND SFT.FT_TIPOMOV = 'S'
		AND SF3.F3_TIPO = 'S' 
		AND SF3.F3_SERIE BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
		AND SF3.F3_NFISCAL BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
		AND SF3.F3_EMISSAO BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
		AND SF3.F3_CLIEFOR BETWEEN %EXP:MV_PAR07% AND %EXP:MV_PAR09%
		AND SF3.F3_LOJA BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR10%
		AND SF3.F3_CODNFE <> ''
		AND ( SF3.F3_OBSERV = %EXP:cWhere1% OR SF3.F3_OBSERV = %EXP:cWhere2% )

	EndSql

	// Posiciona no topo do arquivo
	( cTrab )->( DbGoTop() )

	// Conta quantas notas localizadas
	while ( cTrab )->( !Eof() )

		if aScan( aSeq, ( cTrab )->SEQUENCIAL_NFSE ) == 0

			aAdd( aSeq, ( cTrab )->SEQUENCIAL_NFSE )

		endIf

		( cTrab )->( DbSkip() )

	endDo

	nTotalNFs := Len( aSeq )

	// Reposiciona no topo do arquivo
	( cTrab )->( DbGoTop() )

return

/*/{Protheus.doc} ProcTxt
Gera o arquivo texto para prefeitura.
@type function
@version 12.1.27  
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function ProcTxt()

	local cPath := AllTrim( MV_PAR11 )
	Local cFile := ''
	Local dDate := Date()

	Private nHandle := 0

	if Rat('\',cPath) < Len( AllTrim( cPath ) )

		cPath += '\'

	endif

	cFile += 'envio_'
	cFile += AllTrim( SM0->M0_CGC )
	cFile += StrZero( Day ( dDate ), 2 )
	cFile += StrZero( month ( dDate ), 2 )
	cFile += SubStr( cValTochar( year ( dDate ) ), 3, 2 )
	cFile += '.txt'

	nHandle := fcreate( cPath + cFile )

	if nHandle < 0

		Alert('Erro ao criar o arquivo: ' + cValToChar( ferror() )  )

	else

		GeraHeader()  // Gera Registro Tipo 1 – Header do Arquivo
		GeraLote()    // Gera Registro Tipo 2,3,4,5,6
		GeraTrailer() // Gera Registro Tipo 7 – Indicador de Final de Arquivo:

		fclose(nHandle)

	endif

return

/*/{Protheus.doc} GeraHeader
Gera o header do arquivo, Registro Tipo 1 – Header do Arquivo
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function GeraHeader()

	Local cLine     := ''

	cLine += '1'                                // 01 - Tipo do Registro
	cLine += '109'                              // 02 - Versão do Layout
	cLine += PadR( SM0->M0_INSCM, 26 )          // 03 - Inscrição Municipal do Prestador
	cLine += '2'                                // 04 - Indicador de CPF/CNPJ do Prestador
	cLine += PadR( SM0->M0_CGC, 14 )            // 05 - CNPJ ou CPF do Prestador
	cLine += PadR( MV_PAR12, 1 )                // 06 - Optante pelo Simples
	cLine += PadR( DtoS( MV_PAR05 ), 8 )        // 07 - Data de Início do Período
	cLine += PadR( DtoS( MV_PAR06 ), 8 )        // 08 - Data de Fim do Período
	cLine += PadR( StrZero( nTotalNFs, 5 ), 5 ) // 09 - Quantidade de NFS-e informadas
	cLine += '2'                                // 10 - Quantidade de Casas Decimais para o Valor de Serviço
	cLine += '2'                                // 11 - Quantidade de Casas Decimais para a Quantidade de um Serviço

	addLine( cLine )

return

/*/{Protheus.doc} GeraLote
Gera os registro 2, 3, 4, 5, 6 correspondentes a cada nota
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function GeraLote()

	Local bProcLote := ''

	bProcLote := '{||'
	bProcLote += 'GeraCabNf(),'  // Gera Registro Tipo 2 – Cabeçalho da NFS-e
	bProcLote += 'GeraTomNf(),'  // Gera Registro Tipo 3 – Identificação do Tomador da NFS-e
	bProcLote += 'GeraObsNf(),'  // Gera Registro Tipo 4 – Observação da NFS-e
	bProcLote += 'GeraDcServ()' // Gera Registro Tipo 5 – Descrição do Serviço Realizado
	bProcLote += '}'

	bProcLote := &bProcLote

	( cTrab )->( DbGoTop() )

	while ! ( cTrab )->( Eof() )

		MsgRun( 'Processando Nota fiscal ...', 'Aguarde ...', bProcLote )

	enddo

return

/*/{Protheus.doc} GeraCabNf
Gera Registro Tipo 2 – Cabeçalho da NFS-e
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function	GeraCabNf()

	Local cLine     := ''

	cLine += '2'                                              // 01 - Tipo do Registro
	cLine += PadR( ( cTrab )->SEQUENCIAL_NFSE, 20 )           // 02 - Seqüencial da NFS-e
	cLine += PadR( AllTrim( ( cTrab )->DATA_HORA_NFSE ), 14 ) // 03 - Data e Hora da NFS-e
	cLine += 'N'                                              // 04 - Tipo de Recolhimento
	cLine += PadR( ( cTrab )->SITUACAO_NFSE, 1 )              // 05 - Situação da Nota Fiscal
	cLine += PadR( ( cTrab )->DATA_CANCELAMENTO_NFSE, 8 )     // 06 - Data de Cancelamento
	cLine += PadR( SM0->M0_CODMUN, 7 )                        // 07 - Município de prestação do serviço
	cLine += formatNum( ( cTrab )->TOTAL_SERVICOS, 15 )       // 08 - Valor Total dos Serviços
	cLine += StrZero( 0, 15 )                                 // 09 - Valor Total das Deduções
	cLine += StrZero( 0, 15 )                                 // 10 - Valor da retenção do PIS
	cLine += StrZero( 0, 15 )                                 // 11 - Valor da retenção do COFINS
	cLine += StrZero( 0, 15 )                                 // 12 - Valor da retenção do INSS
	cLine += StrZero( 0, 15 )                                 // 13 - Valor da retenção do IR
	cLine += StrZero( 0, 15 )                                 // 14 - Valor da retenção do CSLL
	cLine += formatNum( ( cTrab )->TOTAL_ISSQN, 15)           // 15 - Valor do ISSQN
	cLine += 'M'                                              // 16 - Local da Prestação
	cLine += PadR( '', 20 )                                   // 17 - Seqüencial da NFS-e à ser Substituída
	cLine += StrZero( 0, 15 )                                 // 18 - Outros Descontos

	addLine( cLine )

return

/*/{Protheus.doc} GeraTomNf
Gera Registro Tipo 3 – Identificação do Tomador da NFS-e
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function	GeraTomNf()

	Local cLine     := ''

	cLine += '3'                                                        // 01 - Tipo do Registro
	cLine += PadR( ( cTrab )->SEQUENCIAL_NFSE, 20 )                     // 02 - Seqüencial da NFS-e
	/*TODO O cadastro de clientes vindo do CMNET está tratando indicador de CPF ou CNPJ ? 
			Este campo indica o tipo de dados fornecido no campo CPF/CNPJ do Tomador.
				Valor 1 para CPF.
				Valor 2 para CNPJ.
				Valor 3 para Não Identificado. (Quando usada esta opção as demais à baixo não serão obrigatórias).
				Valor 9 para Estrangeiro. (Quando usada esta opção deve se informar um documento no campo abaixo que identifique o estrangeiro como por exemplo o passaporte).
	*/
	cLine += ( cTrab )->INDICADOR_CPF_CNPJ                              // 03 - Indicador de CPF/CNPJ do Tomador
	/*TODO O cadastro de clientes vindo do CMNET está tratando o campo de documento de estrangeiro ?
			CNPJ do Tomador com 14 posições,
			CPF do Tomador com 11 posições.
			Sem formatação (ponto, traço, barra, ...) alinhados à esquerda ou Documento para os casos de Estrangeiro
	*/
	cLine += PadR( ( cTrab )->TOMADOR_DOCUMENTO , 14 )                 // 04 - CNPJ, CPF do Tomador/(Documento)
	cLine += PadR( ( cTrab )->NOME_TOMADOR, 50 )                       // 05 - Nome do Tomador
	cLine += PadR( ( cTrab )->NOME_FANTASIA, 50 )                      // 06 - Nome Fantasia
	cLine += PadR( 	getEnderec( ( cTrab )->TOMADOR_ENDERECO )[1], 3 )  // 07 - Tipo de Endereço do Tomador
	cLine += PadR( 	getEnderec( ( cTrab )->TOMADOR_ENDERECO )[2], 50 ) // 08 - Endereço do Tomador
	cLine += PadR( 	getEnderec( ( cTrab )->TOMADOR_ENDERECO )[3], 10 ) // 09 - Número do Endereço do Tomador
	cLine += PadR( ( cTrab )->COMPLEMENTO_TOMADOR, 20 )                // 10 - Complemento do Endereço do Tomador
	cLine += PadR( ( cTrab )->BAIRRO_TOMADOR, 30 )                     // 11 - Bairro do Tomador
	cLine += PadR( ( cTrab )->CIDADE_TOMADOR, 50 )                     // 12 - Cidade do Tomador
	cLine += PadR( ( cTrab )->UF_TOMADOR, 2 )                          // 13 - UF do Tomador
	cLine += PadR( ( cTrab )->CEP_TOMADOR, 8 )                         // 14 - CEP do Tomador
	cLine += PadR( ( cTrab )->EMAIL_TOMADOR, 60 )                      // 15 - E-Mail do Tomador
	cLine += PadR( ( cTrab )->IE_TOMADOR, 20 )                         // 16 - Inscrição Estadual Tomador

	addLine( cLine )

return

/*/{Protheus.doc} GeraObsNf
Gera Registro Tipo 4 – Observação da NFS-e
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function	GeraObsNf()

	Local cLine     := ''

	cLine += '4'                                    // 01 - Tipo do Registro
	cLine += PadR( ( cTrab )->SEQUENCIAL_NFSE, 20 ) // 02 - Seqüencial da NFS-e
	/*TODO Onde buscar as observações da Nota Fiscal ?
			Parece que é preenchido com o código e nome do hóspede, verificar
	*/
	cLine += PadR( ' ', 255 )                       // 03 - Observação da Nota

	addLine( cLine )

return

/*/{Protheus.doc} GeraDcServ
Gera Registro Tipo 5 – Descrição do Serviço Realizado
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/ 
static function	GeraDcServ()

	Local cLine := ''
	Local cSeq  := ( cTrab )->SEQUENCIAL_NFSE

	Private cInscMnTom := PadR( ( cTrab )->INSCR_MUNIC_TOM, 20 )

	while .T.

		cLine += '5'                                              // 01 - Tipo do Registro
		cLine += PadR( ( cTrab )->SEQUENCIAL_NFSE, 20 )           // 02 - Seqüencial da NFS-e

		// 03 - Código do serviço prestado
		if ! Empty( ( cTrab )->COD_LC_PRD )

			cLine += PadR( ( cTrab )->COD_LC_PRD, 4 )

		elseIf ! Empty( ( cTrab )->COD_LC )

			cLine +=  PadR( ( cTrab )->COD_LC, 4 )

		else

			cLine += 'XXXX'

		endIf

		cLine += PadR( ( cTrab )->COD_TRIB_MUNICIPIO, 20 )   // 04 - Código Tributação Município
		cLine += formatNum( ( cTrab )->VALOR_SERVICOS, 15 )  // 05 - Valor do Serviço
		cLine += StrZero( 0, 15 )                            // 06 - Valor Dedução
		cLine += formatNum( ( cTrab )->ALIQUOTA_ISS, 4 )     // 07 - Alíquota
		cLine += PadR( ( cTrab )->UNIDADE, 20 )              // 08 - Unidade
		cLine += formatNum( ( cTrab )->QUANTIDADE, 8 )       // 09 - Quantidade

		//TODO Correto buscar a descrição do serviço na descrição na descrição do produto ?
		cLine += PadR( ( cTrab )->DESCRICAO_SERVICO, 255 )   // 10 - Descrição do Serviço
		cLine += ''                                          // 11 - Alvará
		cLine += ''                                          // 12 - Atividade

		addLine( cLine )

		cLine := ''

		( cTrab )->( DbSkip() )

		if cSeq != ( cTrab )->SEQUENCIAL_NFSE

			GeraCmpTom() // Gera Registro Tipo 6 – Dados Complementares do Tomador

			exit

		endIf

	endDo

return

/*/{Protheus.doc} GeraCmpTom
Gera Registro Tipo 6 – Dados Complementares do Tomador
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/ 
static function	GeraCmpTom()

	Local cLine      := ''

	if !Empty( cInscMnTom )

		cLine += '6'        // 01 - Tipo do Registro
		cLine += cInscMnTom // 02 - Inscrição Municipal do Tomador

		addLine( cLine )

	endif

return

/*/{Protheus.doc} GeraTrailer
Gera o trailer do arquivo, Registro Tipo 7 – Indicador de Final de Arquivo
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/05/2021
/*/
static function GeraTrailer()

	Local cLine     := ''

	cLine += '7' // 01 - Tipo do Registro

	addLine( cLine )

return

/*/{Protheus.doc} addLine
Função que completa a linha com brancos a direita, adiciona a numeração sequencial e inclui o line feed.
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 18/05/2021
@param cLine, character, Conteúdo a linha a ser tratado e adcionado no arquivo
/*/
static function addLine( cLine )

	cLine := PadR( cLine, 391 )
	cLine += StrZero( nSequencial++, 8 )
	cLine += LF

	FWrite( nHandle, cLine )

return

/*/{Protheus.doc} formatNum
Formata um número para o que o layout define e completa com zeros conforme o tamanho solicitado.
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 18/05/2021
@param nNum, numeric, Número a ser formatado
@param nLen, numeric, Tamanho a ser retornado 
@return character, Número em formato character na formatação definida
/*/
static function formatNum( nNum, nLen )

	Local cRet := ''

	cRet := Str( nNum,, 2 )
	cRet := StrZero( Val( cRet ) * 100, nLen )

return cRet

/*/{Protheus.doc} getEnderec
Separa em um array do endereço completo do tomador o tipo do endereço, o nome do endereço e número do endereço
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 18/05/2021
@param cEndereco, character, Endereço completo do Tomador
@return array, Array com o tipo de endereço, nome do endereço e o número do endereço. 
/*/
static function getEnderec( cEndereco )

	Local aRet   := {}
	Local cLogr  := ''
	Local cEnder := ''
	Local cNum   := ''

	cEndereco := AllTrim( cEndereco )

	cLogr := AllTrim( SubStr( cEndereco, 1, at( ' ', cEndereco ) ) )

	cEnder := SubStr( cEndereco, Len( cLogr ) + 1, Len( cEndereco ) )
	cEnder := SubStr( cEnder, 1, Rat( ',', cEnder ) - 1 )

	cEnder := AllTrim( cEnder )

	cNum := AllTrim( SubStr( cEndereco, Rat( ',', cEndereco ) + 1, Len( cEndereco ) ) )

	cNum := AllTrim( cNum )

	aAdd( aRet, cLogr  )
	aAdd( aRet, cEnder )
	aAdd( aRet, cNum   )

return aRet

/*/{Protheus.doc} ImpControl
Função que gera o relatório de controle do envio de NFS-e para prefeitura UNA-BA
@type function
@version 12.1.27  
@author elton.alves@totvs.com.br
@since 24/05/2021
/*/
static function ImpControl()

	Private cNome        := 'NFSEUNAREL'
	Private cTitulo      := "Relação de NFSe UNA-BA"
	Private cPerguntas   := 'NFSEUNAREL'
	Private bBlocoCodigo := { || ReportExec() }
	Private cDescricao   := "Relação de NFSe UNA-BA"
	Private oReport      := TReport():New( cNome, cTitulo, cPerguntas, bBlocoCodigo, cDescricao )
	Private cAlias       := GetNextAlias()
	Private oSection     := TRSection():New( oReport , cDescricao, { cAlias },,.F. )
	Private aCampos      := {}

	// TODO Verificar a necessidade da inclusão no relatório da chave de verificação da NFS-e além do número informado no arquivo de retorno

	if Pergunte( cPerguntas, .T. )

		oReport:SetLandscape()

		oReport:ShowParamPage( )

		oReport:PrintDialog()

	endIf

return

/*/{Protheus.doc} ReportExec
Função invocada na geração do relatório de controle do envio de NFS-e para prefeitura UNA-BA
@type function
@version 12.1.27  
@author elton.alves@totvs.com.br
@since 24/05/2021
/*/
Static Function ReportExec()

	Local nX := 0
	local cWhere1 := ''
	local cWhere2 := 'NF CANCELADA'


	if MV_PAR11 == 2 // Apenas Não Canceladas

		cWhere2 := ''

	ElseIf MV_PAR11 == 3 // Apenas Canceladas

		cWhere1 := 'NF CANCELADA'

	endIf

	BeginSql alias cAlias

		COLUMN F3_EMISSAO AS DATE
		COLUMN F3_DTCANC AS DATE

		SELECT DISTINCT
		SF3.F3_FILIAL,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_CODNFE,SF3.F3_NFELETR,SF3.F3_EMISSAO,
		SF3.F3_NFELETR,SF3.F3_OBSERV,SF3.F3_DTCANC,SF3.F3_CLIEFOR,SF3.F3_LOJA,SA1.A1_NOME
		
		FROM %TABLE:SF3% SF3

		LEFT JOIN %TABLE:SFT% SFT
		ON SF3.F3_FILIAL = SFT.FT_FILIAL
		AND SF3.F3_EMISSAO = SFT.FT_EMISSAO
		AND SF3.F3_SERIE = SFT.FT_SERIE
		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL
		AND SF3.F3_DTCANC = SFT.FT_DTCANC	

		LEFT JOIN %TABLE:SA1% SA1 
		ON SA1.A1_COD = SF3.F3_CLIEFOR
		AND SA1.A1_LOJA = SF3.F3_LOJA
		
		WHERE SF3.%NOTDEL%
		AND SF3.%NOTDEL%
		AND SF3.F3_FILIAL = %XFILIAL:SFT%
		AND SFT.FT_TIPOMOV = 'S' //Define nota de saída
		AND SF3.F3_TIPO = 'S' //Define Nota de serviço
		AND SF3.F3_SERIE BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
		AND SF3.F3_NFISCAL BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
		AND SF3.F3_EMISSAO BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
		AND SF3.F3_CLIEFOR BETWEEN %EXP:MV_PAR07% AND %EXP:MV_PAR09%
		AND SF3.F3_LOJA BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR10%
		AND ( SF3.F3_OBSERV = %EXP:cWhere1% OR SF3.F3_OBSERV = %EXP:cWhere2% )

	EndSql

	oReport:SetMeter(0)

	For nX := 1 To ( cAlias )->( FCount() )

		cCampo   := ( cAlias )->( FieldName( nX ) )
		cTitulo  := GetSx3Cache( cCampo, 'X3_TITULO'  )
		cPicture := GetSx3Cache( cCampo, 'X3_PICTURE' )
		nTamanho := GetSx3Cache( cCampo, 'X3_TAMANHO' )

		TRCell():New( oSection, cCampo, cAlias, cTitulo, cPicture, nTamanho  )

	Next

	oSection:init()

	(cAlias)->( DbGoTop() )

	While ! ( cAlias )->( Eof() )

		For nX := 1 To ( cAlias )->( FCount() )

			cCampo   := ( cAlias )->( FieldName( nX ) )
			xValor   := ( cAlias )->&( FieldName( nX ) )

			oSection:Cell( cCampo ):SetValue( xValor )

		Next

		oSection:Printline()

		(cAlias)->(dbSkip())

	EndDo

	oSection:Finish()

	(cAlias)->( DbCloseArea() )

Return

/*/{Protheus.doc} ImportaTxt
Rotina de importa o código gerado da nota fiscal eletrônica
@type function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 24/05/2021
/*/
static function ImportaTxt()

	Local cFile    := ''
	Local nHandle  := 0
	Local cLinha   := ''
	Local cTipoLn  := ''
	Local cCnpj    := ''
	Local cNumSeq  := ''
	Local cNumNFSe := ''

	// TODO Verificar a necessidade da inclusão na tabela SFT da chave de verificação da NFS-e além do número informado no arquivo de retorno

	if pergunte('NFSEUNAIMP')

		cFile := MV_PAR01
		nHandle := FT_FUse( cFile )

		if nHandle < 0

			Alert('Erro ao abrir o arquivo: ' + cValToChar( fError() )  )

		else

			FT_FGoTop()

			While ! FT_FEOF()

				cLinha   := FT_FReadLn()
				cTipoLn  := SubStr( cLinha, 1, 1 )
				cCnpj    := AllTrim( SubStr( cLinha, 32, 14 ) )
				cNumSeq  := AllTrim( SubStr( cLinha, 02, 20 ) )
				cNumNFSe := AllTrim( SubStr( cLinha, 22, 20 ) )

				if cTipoLn == '1' .And. cCnpj != AllTrim( SM0->M0_CGC )

					Alert( 'O processamento deve ser executado na Filial de CNPJ: ' +;
						Transform( cCnpj, '@R 99.999.999/9999-99' ) )

					Exit

				elseIf cTipoLn == '2'

					if TCSqlExec( "UPDATE " + RetSqlName('SF3') +;
							" SET F3_NFELETR = '" + cNumNFSe +;
							"' WHERE F3_NFELETR = '' AND F3_CODNFE = '" + cNumSeq +;
							"' AND D_E_L_E_T_ = ' ' " ) < 0

						ApMsgAlert( TCSQLError(), 'Erro na execução ' )

					endIf

					if TCSqlExec( "UPDATE " + RetSqlName('SFT') +;
							" SET FT_NFELETR = '" + cNumNFSe +;
							"' WHERE FT_NFELETR = '' AND FT_CODNFE = '" + cNumSeq +;
							"' AND D_E_L_E_T_ = ' ' " ) < 0

						ApMsgAlert( TCSQLError(), 'Erro na execução ' )

					endIf

				endIf

				FT_FSKIP()

			endDo

		endIf

	endif

return
