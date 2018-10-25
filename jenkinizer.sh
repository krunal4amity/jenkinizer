#!/bin/sh
#------------------------------------------------------------------------------------
#The script can be use to perform various operations exposed through Jenkins REST API
#through commandline.
#
# Author: Krunal Shimpi
#------------------------------------------------------------------------------------


login_details (){
	if [ "$JENKINS_URL" == "" ] || [ "$JENKINS_USER" == "" ] || [ "$JENKINS_PASSWORD" == "" ]; then
		read -p 'Enter Jenkins URL: ' JENKINS_URL
		read -p 'Enter Jenkins username:' JENKINS_USER
		read -sp 'Enter Jenkins user password: ' JENKINS_PASSWORD
		echo
	fi
	jenkins_jar
}

jenkins_jar(){
	if [ -e jenkins-cli.jar ]; then
		return 0
	else 
		echo "Downloading jenkins-cli.jar...."
		curl -u $JENKINS_USER:$JENKINS_PASSWORD $JENKINS_URL/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
	fi
}

force_login() {
	if [ "$JENKINS_USER" == "" ]; then
		echo "You haven't logged in yet. Initiating log-in... "
		login_details
	fi
}

create_job (){
	force_login
	if [ "$?" -eq 0 ]  && [ "$#" -eq 2 ]; then
	echo
#	curl -s -X POST -u $JENKINS_USER:$JENKINS_PASSWORD --header "Content-Type: text/xml" --header "Jenkins-Crumb: $(curl -s -u krunal:Welcome1 $JENKINS_URL/crumbIssuer/api/json | cut -d "," -f2 | cut -d ":" -f2 | sed 's/"//g')" -d @"$2" $JENKINS_URL/createItem?name=$1
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD create-job $1 < $2
		if [ "$?" -eq 0 ]; then
			echo "Create-job: Jenkins job named $1 created successfully..."
		else
			echo "Create-job: Oops ! An error occurred while creating the jenkins job.."
		fi
	else
		echo
		echo "Create-job: Either login credentials or number of arguments supplied are wrong."
	fi
	
}

install_plugin (){
	force_login
	if [ "$?" -eq 0 ]  && [ "$#" -eq 1 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD install-plugin $1 -deploy
		if [ "$?" -eq 0 ]; then
			echo "Install-plugin: Jenkins plugin installed successfully..."
		else
			echo "Install-plugin: Oops ! An error occurred while installing jenkins plugin.."
		fi
	else
		echo
		echo "Install-plugin: Either login credentials or number of arguments supplied are wrong."
	fi
	
}

list_plugin (){
	force_login
	if [ "$?" -eq 0 ]  && [ "$#" -eq 1 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD list-plugins $1
		if [ "$?" -eq 0 ]; then
			echo "List-plugin: Jenkins plugin $1 exists..."
		else
			echo "List-plugin: Plugin not found or error occurred while listing plugins..."
		fi
	else
		echo
		echo "List-plugin: Either login credentials or number of arguments supplied are wrong."
	fi
}

list_jobs (){
	force_login
	if [ "$?" -eq 0 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD list-jobs
		if [ "$?" -eq 0 ]; then
			echo "List-job: Jenkins existing jobs are listed above..."
		else
			echo "List-job: Oops ! An error occurred while listing jenkins jobs..."
		fi
	else
		echo
		echo "List-job: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}

restart (){
	force_login
	if [ "$?" -eq 0 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD restart
		if [ "$?" -eq 0 ]; then
			echo "Restart: Jenkins restart executed successfully..."
		else
			echo "Restart: Oops !! An error occurred while Restarting jenkins.."
		fi
	else
		echo
		echo "Restart: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}

## TODO: somehow delete multiple jobs is not working thorugh the script.
delete_jobs (){
	force_login
	if [ "$?" -eq 0 ] && [ "$#" -ne 0 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD delete-job $1
		if [ "$?" -eq 0 ]; then
			echo "Delete-job: Jenkins jobs $@ deleted successfully..."
		else
			echo "Delete-job: Oops !! An error occurred while deleting the jenkins job.."
		fi
	else
		echo
		echo "Delete-job: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}

copy_job (){
	force_login
	if [ "$?" -eq 0 ] && [ "$#" -eq 2 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD copy-job $1 $2
		if [ "$?" -eq 0 ]; then
			echo "Copy-job: Jenkins jobs $1 copied successfully to $2..."
		else
			echo "Copy-job: Oops !! An error occurred while copying the jenkins job.."
		fi
	else
		echo
		echo "Copy-job: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}


enable_job (){
	force_login
	if [ "$?" -eq 0 ] && [ "$#" -eq 1 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD enable-job $1
		if [ "$?" -eq 0 ]; then
			echo "Enable-job: Jenkins jobs $1 enabled successfully ..."
		else
			echo "Enable-job: Oops !! An error occurred while enabling the jenkins job.."
		fi
	else
		echo
		echo "Enable-job: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}

disable_job (){
	force_login
	if [ "$?" -eq 0 ] && [ "$#" -eq 1 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD disable-job $1
		if [ "$?" -eq 0 ]; then
			echo "Disable-job: Jenkins jobs $1 disabled successfully ..."
		else
			echo "Disable-job: Oops !! An error occurred while disabling the jenkins job.."
		fi
	else
		echo
		echo "Disable-job: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}

get_job (){
	force_login
	if [ "$?" -eq 0 ] && [ "$#" -eq 1 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD get-job $1 > "$1.xml"
		if [ "$?" -eq 0 ]; then
			echo "Get-job: Jenkins job $1 xml definition extracted successfully. Please check the current folder for $1.xml file..."
		else
			echo "Get-job: Oops !! An error occurred while getting xml definition of the jenkins job.."
		fi
	else
		echo
		echo "Get-job: Either login credentials or number of arguments supplied are wrong. "
		
	fi
}


update_job (){
	force_login
	if [ "$?" -eq 0 ]  && [ "$#" -eq 2 ]; then
	echo
	java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD update-job $1 < $2
		if [ "$?" -eq 0 ]; then
			echo "Update-job: Jenkins job named $1 updated successfully..."
		else
			echo "Update-job: Oops ! An error occurred while updating the jenkins job.."
		fi
	else
		echo
		echo "Update-job: Either login credentials or number of arguments supplied are wrong."
	fi
}


build_job (){
	force_login
	if [ "$?" -eq 0 ]  && [ "$#" -eq 1 ]; then
	echo
	echo
	read -p 'Do you want to check for SCM changes before starting the build. Enter y/n : ' CHECK_SCM
	read -p 'Is your job parameterized. If so please pass input params separated by space. e.g. key1=value1 key2=value2. If no parameters required then just press enter : ' INPUT_PARAM
	echo
	echo
	
		if [ "$CHECK_SCM" == "y" ] && [ "$INPUT_PARAM" == "" ]; then
			java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD build $1 -c -f -v -w
			if [ "$?" -eq 0 ]; then
				echo
				echo "Build-job: Jenkins job named $1 executed successfully. Although based on SCM selection the job might not have run. Please check on jenkins console."
			else
				echo
				echo "Build-job: Oops ! An error occurred while building the jenkins job.."
			fi
		elif [ "$CHECK_SCM" == "y" ] && [ "$INPUT_PARAM" != "" ]; then
			java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD build $1 -c -f -v -w -p $(echo $INPUT_PARAM | sed 's/ / -p /g')
			if [ "$?" -eq 0 ]; then
				echo
				echo "Build-job: Jenkins job named $1 ran successfully. Although based on SCM selection the job might not have run. Please check on jenkins console."
			else
				echo
				echo "Build-job: Oops ! An error occurred while building the jenkins job.."
			fi		
		elif [ "$CHECK_SCM" == "n" ] && [ "$INPUT_PARAM" == "" ]; then
			java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD build $1 -f -v -w
			if [ "$?" -eq 0 ]; then
				echo
				echo "Build-job: Jenkins job named $1 ran successfully..."
			else
				echo
				echo "Build-job: Oops ! An error occurred while building the jenkins job.."
			fi	
		else
			java -jar ./jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASSWORD build $1 -f -v -w -p $(echo $INPUT_PARAM | sed 's/ / -p /g')
			if [ "$?" -eq 0 ]; then
				echo
				echo "Build-job: Jenkins job named $1 ran successfully..."
			else
				echo
				echo "Build-job: Oops ! An error occurred while building the jenkins job.."
			fi
		fi
	else
		echo
		echo "Update-job: Either login credentials or number of arguments supplied are wrong."
	fi
}

case "$1" in
  list-jobs)
    list_jobs
    ;;
  delete-jobs)
    delete_jobs $2
    ;;
  enable-job)
    enable_job $2
    ;;
  disable-job)
    disable_job $2
    ;;
  get-job)
    get_job $2
    ;;
  restart)
    restart $2
    ;;
  build-job)
    build_job $2
    ;;	
  list-plugin)
    list_plugin $2
    ;;	
  create-job)
    create_job $2 $3
    ;;
  update-job)
    update_job $2 $3
    ;;
  install-plugin)
    install_plugin $2
    ;;
  copy-job)
    copy_job $2 $3
    ;;
  *)
    echo "Usage: `basename $0` [Verb] [[PARAMS][PARAMS][PARAMS]]"
    echo "  list-jobs - list Jenkins jobs"
    echo "  delete-jobs [job1] [job2]...  - Delete job(s) supplied as arguments. Can accept more than one jobname at a time..."
	echo "  create-job [jobname] [config.xml_file_fullpath] - create a jenkins job with the name supplied. "
	echo "  update-job [jobname] [config.xml_file_fullpath] - updates the existing jenkins job with the name supplied. "	
	echo "  copy-job [source job] [destination job] - copy a jenkins job"
	echo "  enable-job [jobname]  - enable a jenkins job"
	echo "  disable-job [jobname] - disable a jenkins job"
	echo "  get-job [jobname]  - Get xml definition of the jenkins job"
	echo "  restart  - restarts jenkins"
	echo "  install-plugin [plugin_url]  - Provide the plugin url that DOES NOT do any http redirects and is a direct link to plugin file."
	echo "  build-job [jobname]  - Run the build of the jenkins jobs name specified"	
    exit 1
esac
exit $?

