##���ɴ������ݿ�Ľű�
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
    #databases�ű�ѡ������
    $ScriptingOptionsDB = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions"      
    #db_objects�ű�ѡ������
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
		Write-Host "��ʼ�������ݿ�:" $database		
		$MySrv=$MyServer.databases["$database"]
		if($MySrv)
		{
    		#������ݿ��е��û����ݿ�
    		foreach($s in $MySrv.Script($ScriptingOptionsDB))
    		{
    			#�������ݿ��ļ���ʼ��С
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
    		Write-Host "�������û����ݿ� ( 1 / 1) : "  $database    		
			$i=$Sript.AppendLine("Use $database") 
			$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n")	
			#������ݿ��е��û�
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

					Write-Host "�������û� (" $count "/" $Users.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}		
    		#������ݿ��еļܹ�
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

					Write-Host "������ܹ� (" $count "/" $Schemas.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			} 	
			#������ݿ��е��û���
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

					Write-Host "������� (" $count "/" $Tables.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}   
			
			#������ݿ��е���ͼ
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

					Write-Host "��������ͼ (" $count "/" $Views.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}  
			
			#������ݿ��е��Զ��庯��
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

					Write-Host "�������Զ��庯�� (" $count "/" $UserDefinedFunctions.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}   
			
			#������ݿ��еĴ洢����
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

					Write-Host "������洢���� (" $count "/" $StoredProcedures.Count ")"  ": " $tb.Name 
					$count+=1 
		  
				}
				$i=$Sript.AppendLine("`r`n"+"Go"+"`r`n") 
			}  

		}   
		Else
		{
			Write-Error "��Ч�����ݿ⣺ $database ��"
		}
		
		Write-Host "�����������ݿ�:"$database
		Write-Host ""
	}
	
    #����ű�        
    [string]$Path=$SrciptOutputPath+$SrciptOutputFileName
    $Sript.ToString() | Out-File -FilePath $Path    
    Write-Host "�������ݿ�ű��ɹ�"
}
