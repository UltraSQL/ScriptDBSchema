##生成创建数据库的脚本
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
    #databases脚本选项设置
    $ScriptingOptionsDB = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions"      
    #db_objects脚本选项设置
    $ScriptingOptions = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions"
    #$ScriptingOptions.AgentAlertJob	
	#$ScriptingOptions.AgentJobId
	#$ScriptingOptions.AgentNotify
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
	$ScriptingOptions.NoIdentities								= $False
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
	$ScriptingOptions.SchemaQualify							    = $True
	$ScriptingOptions.SchemaQualifyForeignKeysReferences		= $True
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
		Write-Host "开始处理数据库:" $database		
		$MySrv=$MyServer.databases["$database"]
		if($MySrv)
		{
    		#获得数据库中的用户数据库
    		foreach($s in $MySrv.Script($ScriptingOptionsDB))
    		{
    			#设置数据库文件初始大小
    			if( $s.IndexOf(", SIZE") -gt 0 )
    			{
    				$s.IndexOf(", SIZE")
    				$s.Substring($s.IndexOf(", SIZE"), $s.IndexOf(", MAXSIZE") - $s.IndexOf(", SIZE") + 1)

					$s2 = $s.Replace($s.Substring($s.IndexOf(", SIZE"), $s.IndexOf(", MAXSIZE") - $s.IndexOf(", SIZE") + 1), ", SIZE = 10240000KB ,")
					$s3 = $s2.Replace($s2.Substring($s2.IndexOf(", SIZE", $s.IndexOf(", SIZE") + 6), $s2.IndexOf(", MAXSIZE", $s.IndexOf(", MAXSIZE") + 9) - $s2.IndexOf(", SIZE", $s.IndexOf(", SIZE") + 6) + 1), ", SIZE = 1024000KB ,")
					$s=$s3
				}
				$i=$Sript.AppendLine($s)
   				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   
    		}    		
    		$i=$Sript.Replace("ALTER DATABASE [$database] SET PARTNER TIMEOUT 10 ","")    		
    		Write-Host "处理完用户数据库 ( 1 / 1) : "  $database    		
			$i=$Sript.AppendLine("Use $database") 
			$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")	
			#获得数据库中的用户
			$Users=$MySrv.Users | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($Users)
			{
				$count=1
				foreach($tb In $Users | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "处理完用户 (" $count "/" $Users.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}		
    		#获得数据库中的架构
			$Schemas=$MySrv.Schemas | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($Schemas)
			{
				$count=1
				
				foreach($tb In $Schemas | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "处理完架构 (" $count "/" $Schemas.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			} 	
			#获得数据库中的用户表
			$Tables=$MySrv.tables | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($Tables)
			{
				$count=1
				foreach($tb In $Tables | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "处理完表 (" $count "/" $Tables.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}   
			
			#获得数据库中的视图
			$Views=$MySrv.Views | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($Views)
			{
				$count=1
				foreach($tb In $Views | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "处理完视图 (" $count "/" $Views.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}  
			
			#获得数据库中的自定义函数
			$UserDefinedFunctions=$MySrv.UserDefinedFunctions | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($UserDefinedFunctions)
			{
				$count=1
				foreach($tb In $UserDefinedFunctions | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "处理完自定义函数 (" $count "/" $UserDefinedFunctions.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}   
			
			#获得数据库中的存储过程
			$StoredProcedures=$MySrv.StoredProcedures | Where-Object -FilterScript{$_.IsSystemObject -eq $False}
			if($StoredProcedures)
			{
				$count=1
				foreach($tb In $StoredProcedures | Sort-Object -Property CreateDate,ID)
				{
					foreach($s In $tb.Script($ScriptingOptions))
					{   
						$i=$Sript.AppendLine($s)
					}

    				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")   

					Write-Host "处理完存储过程 (" $count "/" $StoredProcedures.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}  

		}   
		Else
		{
			Write-Error "无效的数据库： $database 。"
		}
		
		Write-Host "结束处理数据库:"$database
		Write-Host ""
	}
	
    #输出脚本        
    [string]$Path=$SrciptOutputPath+$SrciptOutputFileName
    $Sript.ToString() | Out-File -FilePath $Path    
    Write-Host "生成数据库脚本成功"
}
