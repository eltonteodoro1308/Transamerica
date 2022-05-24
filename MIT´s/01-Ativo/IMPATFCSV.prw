#include 'totvs.ch'
/*

*/
user function ImpAtfCsv()

	Local cFileIni    := ''
	Local cPath       := ''
	Local cLayoutMile := ''
	Local cSN1File    := ''
	Local aSN3Files   := ''

	Local aSN1        := {}
	Local aSn3Item    := {}
	Local aSN3List    := {}

	cFileIni := fwInputBox( "Arquivo ini de configuração da importação.", cFileIni)

	cPath       := SubStr(cFileIni,1,rat('\',cFileIni))
	cLayoutMile := GetPvProfString( 'IMPATFCSV', 'LAYOUT_MILE' , '', cFileIni )
	cSN1File    := GetPvProfString( 'IMPATFCSV', 'ARQUIVO_SN1' , '', cFileIni )
	aSN3Files   := GetPvProfString( 'IMPATFCSV', 'ARQUIVOS_SN3', '', cFileIni )

	SN1Buffer( aSN1, cSN1File )



return

static function SN1Buffer( aSN1, cSN1File )

return




	// local cFileCab := ""
	// local cFileIt  := ""

	// cFileCab := fwInputBox( "Arquivo com dados dos cabeçalho.", cFileCab)
	// cFileIt  := fwInputBox( "Arquivos com dados dos itens."    , cFileIt )

	// Apontar Arquivo de Cabeçalho
	// Apontar Arquivo de itens de valores


	// Buscar posição dos campos do cabeçalho
	// Buscar posição dos campos de itens de valores

/* 	local aCabec := {}
	local aItem  := {}
	local aItens := {}
	local cBase  := cValToChar(Randomize( 1, 1000000000 ))
	local citem  := cValToChar(Randomize( 1, 1000 ))
	local dAquis := Date()-10

	Private lMsErroAuto := .F.

	rpcsetenv('99','01')

	aAdd( aCabec, { 'N1_GRUPO'   , '0101',nil } )
	aAdd( aCabec, { 'N1_PATRIM'  , 'N',nil } )
	aAdd( aCabec, { 'N1_CBASE'   , cBase,nil } )
	aAdd( aCabec, { 'N1_ITEM'    , cItem,nil } )
	aAdd( aCabec, { 'N1_AQUISIC' , dAquis,nil } )
	aAdd( aCabec, { 'N1_QUANTD'  , 1,nil } )
	aAdd( aCabec, { 'N1_DESCRIC' , 'ATIVO TESTE EXECAUTO',nil } )
	aAdd( aCabec, { 'N1_CHAPA'   , cBase,nil } )
	aAdd( aCabec, { 'N1_APOLICE' , '0000001',nil } )
	aAdd( aCabec, { 'N1_CODSEG'  , '999999',nil } )
	aAdd( aCabec, { 'N1_DTVENC'  , stod('20221201'),nil } )
	aAdd( aCabec, { 'N1_CSEGURO' , 'CIA SEGURADORA PADRAO',nil } )
	aAdd( aCabec, { 'N1_FORNEC'  , '000001',nil } )
	aAdd( aCabec, { 'N1_LOJA'    , '01',nil } )
	aAdd( aCabec, { 'N1_LOCAL'   , '000001',nil } )
	aAdd( aCabec, { 'N1_NFISCAL' , '321654',nil } )
	aAdd( aCabec, { 'N1_CALCPIS' , '2',nil } )
	aAdd( aCabec, { 'N1_CODBAR'  , cBase,nil } )
	aAdd( aCabec, { 'N1_DETPATR' , '01',nil } )
	aAdd( aCabec, { 'N1_UTIPATR' , '1 ',nil } )
	aAdd( aCabec, { 'N1_ORIGCRD' , '0',nil } )
	aAdd( aCabec, { 'N1_CSTPIS'  , '01',nil } )
	aAdd( aCabec, { 'N1_ALIQPIS' , 1.65,nil } )
	aAdd( aCabec, { 'N1_CSTCOFI' , '01',nil } )
	aAdd( aCabec, { 'N1_ALIQCOF' , 7.60,nil } )
	aAdd( aCabec, { 'N1_CODBCC'  , '01',nil } )
	aAdd( aCabec, { 'N1_PRODUTO' , '000001',nil } )


	aAdd( aItem, {'N3_CBASE'   , cBase, nil } )
	aAdd( aItem, {'N3_ITEM'    , cItem, nil } )
	aAdd( aItem, {'N3_TIPO'    , '01', nil } )
	aAdd( aItem, {'N3_HISTOR'  , 'DEPRECIACAO FISCAL', nil } )
	aAdd( aItem, {'N3_CCONTAB' , '1222002', nil } )
	aAdd( aItem, {'N3_CDEPREC' , '4111998', nil } )
	aAdd( aItem, {'N3_CCUSTO'  , '101', nil } )
	aAdd( aItem, {'N3_CCDEPR'  , '1222803', nil } )
	aAdd( aItem, {'N3_DINDEPR' , dAquis, nil } )
	aAdd( aItem, {'N3_VORIG1'  , 15000, nil } )
	aAdd( aItem, {'N3_TXDEPR1' , 10, nil } )
	aAdd( aItem, {'N3_VRDACM1' , 0, nil } )
	aAdd( aItem, {'N3_AQUISIC' , dAquis, nil } )
	aAdd( aItem, {'N3_VMXDEPR' , 0, nil } )
	aAdd( aItem, {'N3_DESCEST' , 'Descrição extendida', nil } )

	aAdd( aItens, aClone( aItem ) )
	aSize( aItem, 0 )

	aAdd( aItem, {'N3_CBASE'   , cBase, nil } )
	aAdd( aItem, {'N3_ITEM'    , cItem, nil } )
	aAdd( aItem, {'N3_TIPO'    , '10', nil } )
	aAdd( aItem, {'N3_HISTOR'  , 'DEPRECIACAO FISCAL', nil } )
	aAdd( aItem, {'N3_CCONTAB' , '1222002', nil } )
	aAdd( aItem, {'N3_CDEPREC' , '4111998', nil } )
	aAdd( aItem, {'N3_CCUSTO'  , '101', nil } )
	aAdd( aItem, {'N3_CCDEPR'  , '1222803', nil } )
	aAdd( aItem, {'N3_DINDEPR' , dAquis, nil } )
	aAdd( aItem, {'N3_VORIG1'  , 15000, nil } )
	aAdd( aItem, {'N3_TXDEPR1' , 10, nil } )
	aAdd( aItem, {'N3_VRDACM1' , 0, nil } )
	aAdd( aItem, {'N3_AQUISIC' , dAquis, nil } )
	aAdd( aItem, {'N3_VMXDEPR' , 0, nil } )
	aAdd( aItem, {'N3_DESCEST' , 'Descrição extendida', nil } )

	aAdd( aItens, aClone( aItem ) )
	aSize( aItem, 0 )

	Begin Transaction

		MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCabec,aItens,3,{})

		If lMsErroAuto

			MostraErro()
			DisarmTransaction()

		Endif

	End Transaction

	rpcclearenv() */

