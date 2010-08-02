
Include ".\Tools\psake\psake_ext.ps1"

properties { 
  $base_dir  = resolve-path .
  $revision =  Generate-Revision(2010)
  $lib_dir = "$base_dir\external"
  $build_dir = "$base_dir\lib" 
  $buildartifacts_dir = "$build_dir\" 
  $sln_file = "$base_dir\Source\FluentMetadata.sln" 
  $version = "0.5.1.$revision"
  $tools_dir = "$base_dir\Tools"
  $release_dir = "$base_dir\Release"
} 

task default -depends Release

task Clean { 
  remove-item -force -recurse $buildartifacts_dir -ErrorAction SilentlyContinue 
  remove-item -force -recurse $release_dir -ErrorAction SilentlyContinue 
} 

task Init -depends Clean { 

    Generate-Assembly-Info `
        -file "$base_dir\Source\GlobalAssemblyInfo.cs" `
        -title "FluentMetadata $version" `
        -description "A Metadata Framework for ASP.MVC and FluentNHibernate" `
        -product "FluentMetadata $version" `
        -version $version `
        -clsCompliant "false" `
        -copyright "Copyright � Albert Weinert 2010"
        
    new-item $release_dir -itemType directory 
    new-item $buildartifacts_dir -itemType directory 
} 

task CopyExternals
{
   exec { Copy-Item $lib_dir\xUnit\*.* $buildartifacts_dir }
}
task Compile -depends Init { 
  exec { msbuild /t:Rebuild /verbosity:minimal "/p:OutDir=$buildartifacts_dir" "/p:Platform=Any CPU" "$sln_file" }
} 

task Test20 -depends Compile  {
  exec { & $tools_dir\xUnit\xunit.console.exe $build_dir\FluentMetadata.Core.Specs.dll }
  exec { & $tools_dir\xUnit\xunit.console.exe $build_dir\FluentMetadata.MVC.Specs.dll }
}

task Test40 -depends Test20  {
  exec { & $tools_dir\xUnit\xunit.console.clr4.exe $build_dir\FluentMetadata.EntityFramework.Specs.dll }
}


task Docu -depends Test40 {
   exec { & $lib_dir\xUnit\ReportGenerator.exe /generator:HTML /path:$build_dir /assembly:$build_dir\FluentMetadata.Core.Specs.dll /assembly:$build_dir\FluentMetadata.MVC.Specs.dll }
}

task Gem -depends Compile {

   copy-item readme.txt $build_dir\readme.txt
   
   $version | out-file .\VERSION -encoding ASCII
   
   exec { gem build .\FluentMetadata.gemspec }
}
task Release -depends Gem {
    
    exec {
    
      & $tools_dir\Zip\zip.exe -9 -A -j `
        $release_dir\FluentMetadata.$version.zip `
        $build_dir\FluentMetadata.Core.dll `
        $build_dir\FluentMetadata.MVC.dll `
        $build_dir\FluentMetadata.FluentNHibernate.dll `
        $build_dir\FluentMetadata.EntityFramework.dll 
    }
}

