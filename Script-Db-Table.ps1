
##生成创建表的脚本，包含Constraints,Indexes,Triggers
param
(
[string] $ip,
[string] $port,
[string] $userName,
[string] $password,
[string] $DataBaseName,
[string] $SrciptOutputPath,
[string] $SrciptOutputFileName
)


[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null

$ConnectionString = "Data Source=$ip,$port;Initial Catalog=master;User ID=$userName;Password=$password;"

$SqlConnection = new-object "System.Data.SqlClient.SqlConnection" $ConnectionString


$ServerConnection = new-object "Microsoft.SqlServer.Management.Common.ServerConnection" $SqlConnection #$serverInstance ,$userName, $password 

#$MySrv = new-object Microsoft.SqlServer.Management.Smo.Server($ServerConnection)



$ServerConnection.Connect()


if($ServerConnection.IsOpen)
{   
    #腳本选项设置
    $ScriptingOptions = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions"
 
    $ScriptingOptions.AgentAlertJob								= $True
	$ScriptingOptions.AgentJobId								= $True
	$ScriptingOptions.AgentNotify								= $True

	#$ScriptingOptions.AllowSystemObjects
	$ScriptingOptions.AnsiFile									= $False
	#$ScriptingOptions.AnsiPadding
	#$ScriptingOptions.AppendToFile
	#$ScriptingOptions.BatchSize
	#$ScriptingOptions.Bindings
	#$ScriptingOptions.ChangeTracking
	
	$ScriptingOptions.ClusteredIndexes							= $True
	
	#$ScriptingOptions.ContinueScriptingOnError
	
	#$ScriptingOptions.ConvertUserDefinedDataTypesToBaseType
	#$ScriptingOptions.DdlBodyOnly
	#$ScriptingOptions.DdlHeaderOnly
	#$ScriptingOptions.Default


	#$ScriptingOptions.DriAll
	$ScriptingOptions.DriAllConstraints							= $True
	$ScriptingOptions.DriAllKeys								= $True
	#$ScriptingOptions.DriChecks
	$ScriptingOptions.DriClustered								= $True
	$ScriptingOptions.DriDefaults								= $True
	$ScriptingOptions.DriForeignKeys							= $True
	#$ScriptingOptions.DriIncludeSystemNames
	$ScriptingOptions.DriIndexes								= $True
	$ScriptingOptions.DriNonClustered							= $True
	$ScriptingOptions.DriPrimaryKey								= $True
	$ScriptingOptions.DriUniqueKeys								= $True
	#$ScriptingOptions.DriWithNoCheck


	#$ScriptingOptions.Encoding
	#$ScriptingOptions.EnforceScriptingOptions
	$ScriptingOptions.ExtendedProperties						= $True
	#$ScriptingOptions.FileName
	#$ScriptingOptions.FullTextCatalogs
	#$ScriptingOptions.FullTextIndexes
	#$ScriptingOptions.FullTextStopLists
	#$ScriptingOptions.IncludeDatabaseContext
	#$ScriptingOptions.IncludeDatabaseRoleMemberships
	#$ScriptingOptions.IncludeFullTextCatalogRootPath
	$ScriptingOptions.IncludeHeaders							= $False
	$ScriptingOptions.IncludeIfNotExists						= $True
	$ScriptingOptions.Indexes									= $True
	#$ScriptingOptions.LoginSid
	#$ScriptingOptions.NoAssemblies
	$ScriptingOptions.NoCollation								= $True
	#$ScriptingOptions.NoCommandTerminator
	#$ScriptingOptions.NoExecuteAs
	$ScriptingOptions.NoFileGroup								= $True
	#$ScriptingOptions.NoFileStream
	#$ScriptingOptions.NoFileStreamColumn
	$ScriptingOptions.NoIdentities								= $True
	#$ScriptingOptions.NoIndexPartitioningSchemes
	#$ScriptingOptions.NoMailProfileAccounts
	#$ScriptingOptions.NoMailProfilePrincipals
	#$ScriptingOptions.NonClusteredIndexes
	#$ScriptingOptions.NoTablePartitioningSchemes
	#$ScriptingOptions.NoVardecimal
	#$ScriptingOptions.NoViewColumns
	#$ScriptingOptions.NoXmlNamespaces
	#$ScriptingOptions.OptimizerData


	$ScriptingOptions.Permissions								= $True
	#$ScriptingOptions.PrimaryObject
	$ScriptingOptions.SchemaQualify								= $True
	#$ScriptingOptions.SchemaQualifyForeignKeysReferences
	#$ScriptingOptions.ScriptBatchTerminator
	#$ScriptingOptions.ScriptData
	#$ScriptingOptions.ScriptDataCompression						
	#$ScriptingOptions.ScriptDrops
	#$ScriptingOptions.ScriptOwner
	$ScriptingOptions.ScriptSchema								= $True
	#$ScriptingOptions.Statistics
	#$ScriptingOptions.TargetDatabaseEngineType
	#$ScriptingOptions.TargetServerVersion
	#$ScriptingOptions.TimestampToBinary
	#$ScriptingOptions.ToFileOnly
	$ScriptingOptions.Triggers									= $True
	#$ScriptingOptions.WithDependencies
	$ScriptingOptions.XmlIndexes								= $True

	$MyServer=(New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerConnection)
	
	$dblist = $DataBaseName.split("")
	
    [System.Text.StringBuilder]$Sript="Use master"  
    $i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")
    		
	For($k = 0 ; $k -le ($dblist.length -1); $k +=1) 
	{
		$database=$dblist[$k]

		$MySrv=$MyServer.databases["$database"]
		if($MySrv)
		{
			$i=$Sript.AppendLine("Use $database") 
			$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")
			#获得数据库中的用户表
			$Tables=$MySrv.tables | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($Tables)
			{
				foreach($tb In $Tables | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "處理完表 (" $count "/" $Tables.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}    
		}
	}
	
	#输出脚本        
	[string]$Path=$SrciptOutputPath+$SrciptOutputFileName
	$Sript.ToString() | Out-File -FilePath $Path
	
}
