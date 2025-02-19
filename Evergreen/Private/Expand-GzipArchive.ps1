Function Expand-GzipArchive {
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { If (Test-Path -Path $_ -PathType "Leaf") { $True } Else { Throw "Cannot find path $_." } })]
        [System.String] $Path,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { If (Test-Path -Path $(Split-Path -Path $_ -Parent) -PathType "Container") { $True } Else { Throw "Cannot find path $(Split-Path -Path $_ -Parent)." } })]
        [System.String] $DestinationPath = ($Path -replace "\.gz$", ""),

        [Parameter()]
        [System.Int32] $BufferSize = 1024
    )

    try {
        # Create the input stream to read the archive
        Write-Verbose -Message "$($MyInvocation.MyCommand): Create input file stream."
        $InputStream = New-Object -TypeName "System.IO.FileStream" $Path, `
        ([System.IO.FileMode]::Open), ([System.IO.FileAccess]::Read), `
        ([System.IO.FileShare]::Read)

        # Create the output stream object
        Write-Verbose -Message "$($MyInvocation.MyCommand): Create output file stream."
        $OutputStream = New-Object -TypeName "System.IO.FileStream" $DestinationPath, `
        ([System.IO.FileMode]::Create), ([System.IO.FileAccess]::Write), `
        ([System.IO.FileShare]::None)

        # Create the Gzip stream to expand the archive
        Write-Verbose -Message "$($MyInvocation.MyCommand): Create Gzip stream."
        $GzipStream = New-Object -TypeName "System.IO.Compression.GzipStream" $InputStream, `
        ([System.IO.Compression.CompressionMode]::Decompress)
    }
    catch {
        Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
    }

    # Expand the archive
    If ($Null -ne $GzipStream) {
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Attempt expand: $DestinationPath."
            $buffer = New-Object -TypeName System.Byte[] -ArgumentList $BufferSize
            While ($true) {
                $read = $GzipStream.Read($buffer, 0, $BufferSize)
                If ($read -le 0) { Break }
                $OutputStream.Write($buffer, 0, $read)
            }
        }
        catch {
            Throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
        }
        finally {
            # Close the streams
            $GzipStream.Close()
            $InputStream.Close()
            $OutputStream.Close()
            Write-Verbose -Message "$($MyInvocation.MyCommand): Successfully expanded: $DestinationPath."
            Write-Output -InputObject $DestinationPath
        }
    }
}
