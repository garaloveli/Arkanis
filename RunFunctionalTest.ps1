param(	
	$Mode = "Debug"    
) 

$msbuildpath = "$($env:windir)\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe"
$ncover = "./packages/OpenCover.4.6.519/tools/OpenCover.Console.exe"
$nreport = "./packages/ReportGenerator.2.5.9/tools/ReportGenerator.exe"
$nunit = "./packages/NUnit.Runners.2.6.4/tools/nunit-console.exe"
$CurrentDirectory =  (Split-Path $MyInvocation.MyCommand.Path -parent)


$NUnitProject = './Tests/Arkanis.FunctionalTests/Arkanis.FunctionalTests.csproj'

& $msbuildpath $NUnitProject /t:build /p:Configuration=$Mode /p:DefineConstants="CODE_ANALYSIS" /verbosity:quiet


if ($lastexitcode -gt 0){
	exit $lastexitcode
}

$output_build = join-path $CurrentDirectory "\Tests\FunctionalTestCoverage\"

if (test-path $output_build ) {
    Remove-Item -recurse -force $output_build/*
}  
else
{
    mkdir  $output_build
}

$tmp_result_cover = join-path $output_build 'FunctionalTestCoverage.xml'         
                          
$NUnitDLL = './Tests/Arkanis.FunctionalTests/bin/Debug/Arkanis.FunctionalTests.dll'

& $ncover -filter:"+[Arkanis*]* -[Polly*]*" -register:user "-target:$nunit" "-targetargs:/noshadow /framework:4.5  $NUnitDLL" -output:"$tmp_result_cover"     

$output_report = join-path $output_build "ReportFunctionalCover" 

& $nreport -reports:$tmp_result_cover -targetdir:$output_report