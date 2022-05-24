#INCLUDE 'TOTVS.CH'
#INCLUDE 'PRCONST.CH'
#INCLUDE 'STDWIN.CH'
#INCLUDE 'FILEIO.CH'

static cprgName   := 'AtfSched'
static cPathSrv   := GetSrvProfString( 'StartPath', '' ) + cprgName + '\'
static cPathStart := cPathSrv + 'start\'
static cPathEnd   := cPathSrv + 'end\'

user function AtfSched( aParam )

	Local aFiles  := Directory( cPathSrv + '*.txt',,,, 2 )
	Local cFile   := ''
	Local oFwMile := nil

	//Default aParam := {'99',,,}

	if ! Empty( aFiles )

		cFile := aFiles[ 1, 1 ]

		moveFile( cPathSrv, cPathStart, cFile )

		if RpcSetEnv( aParam[ Len( aParam ) -  3 ], StrTokArr2( cFile, '.', .T. )[ 1 ] )

			// Processamento do layout do mile
            oFwMile := FwMile():New()
			oFwMile:SetLayout( 'ATFA012' )
			oFwMile:SetTxtFile( cPathStart + cFile )

			If oFWMile:Activate()

				oFWMile:Import()

				If oFWMILE:Error()

					//oFWMILE:GetError()

				endIf

				oFWMile:Deactivate()

			else

				//oFWMILE:GetError()

			endIf

		endIf

		moveFile( cPathStart, cPathEnd, cFile )

		RpcClearEnv()

	endIf

return

static function moveFile( cOrigin, cDestiny, cFile )

	Local nHandle := fOpen( cOrigin + cFile )
	Local nLength := fSeek( nHandle, 0, FS_END )
	Local cBuffer := ''

	fSeek(nHandle, 0)
	cBuffer := fReadStr( nHandle, nLength )

	fClose( nHandle )

	nHandle := fCreate( cDestiny + cFile )

	fWrite( nHandle, cBuffer, len( cBuffer ) )

	fClose( nHandle )

	fErase( cOrigin + cFile )

return

user function AtfSave()

	Local cPathLoc := cGetFile(,,,,.T.,GETF_RETDIRECTORY+GETF_LOCALHARD,.F.)
	Local aFiles   := {}
	Local nX       := 0

	MakeDir( cPathSrv )
	MakeDir( cPathStart )
	MakeDir( cPathEnd )

	aFiles := aClone( Directory( cPathLoc + '*.txt') )

	for nX := 1 to len( aFiles )

		CpyT2S( cPathLoc + aFiles[ nX, 1 ], cPathSrv )

	next nX

return

static function logCv8( cMsg, cDet )

	Default cMsg := ''
	Default cDet := ''

	DbSelectArea( 'CV8' )
	RecLock( 'CV8', .T. )

	CV8->CV8_DATA := Date()
	CV8->CV8_HORA := Time()
	CV8->CV8_MSG  := cMsg
	CV8->CV8_DET  := cDet
	CV8->CV8_PROC := cprgName

	CV8->( MsUnlock() )

return
