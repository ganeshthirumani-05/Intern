#!bin/bash
#notes: keep maintain a function to get status_code
#use_switch_case                

# A shell script to perform git operations

# Help function... 

help(){
echo "usage:     $0 -o [command] [option argument]"
echo "usage:     $0 -h|--help"
echo ""
echo "example usage to perform the github operations"
echo ""
echo "           $0 -o list_repo/repo_list -u {username} -p {password}"
echo "           $0 -o list_of_branches/branchlist -u {username} -p {password} -r {repository name}"
echo "           $0 -o create_branch/branch_create -u {username} -p {password} -r {repository_name} -n {new_branch_name}  -e {source-branch_name}"
echo "           $0 -o delete_branch/del_branch -u {username} -p {password} -r {repository_name}  -b {branch_name}"
echo "           $0 -o listpullreq/pr_list -u {username} -p {password} -r {repository_name}"
echo "           $0 -o close_pullreq -u {username} -p {password} -r {repository_name} -l {pull_number}"
echo "           $0 -o merge_branch/branch_merge -u {username} -p {password} -r {repository_name} -s {source_branch} -d {destination_branch}"
echo ""
echo "Options :"
echo "   -o                      specify the type of operation"
echo "   -u                      specify the username "
echo "   -p                      specify the password or token id for that user to access"
echo "   -r                      specify the repository name of the user"
echo "   -b                      specify the branch name of the repository"
echo "   -n                      specify the new branch to be created on the repository"
echo "   -e                      specify the source branch while creating a new branch on a repository"
echo "   -l                      specify the pull number in the event of closing the pull request"
echo "   -s                      specify the sorce branch in the event of merging branches as a source or as a production branch"
echo "   -d                      specify the destination branch while merging branches and as a current branch to which you want to merge or as a development branch"
echo ""
echo "Commands :"
echo "  list_repo/repo_list               To get the list of repositories on the specified user's account"
echo "  list_of_branches/branchlist       To get the list of all the available branches on the repository specified"
echo "  create_branch/branch_create       To create a new branch in the repository, use a source branch to create a new branch from"
echo "  delete_branch/del_branch          To delete a branch present in a specified repository"
echo "  listpullreq/pr_list               To get the list of all the pull-requests raised whose status is in open along with their pull number"
echo "  close_pullreq                     To close a pull request raised, use pull number to close the request"
echo "  merge_branch/branch_merge         To merge two branches in a specified repository"
exit
}

if [ "$1" == "-help"  -o  "$1" == "--help" -o -z "$1" -o  "$1" == "-h" ]
then 
    help
fi   

while getopts "p:b:u:r:o:s:d:n:e:l:" opt; 
do
  case $opt in
    l)
      pull_number=$OPTARG
      ;;
    e)
      source_reference_branch=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
    b)
      branch_name=$OPTARG
      ;;
    u)
      user_name=$OPTARG
      ;;
    r)
      repo_name=$OPTARG 
      ;;  
    o)
      option=$OPTARG 
      ;;
    s)
      source=$OPTARG 
      ;; 
    d)
      destination=$OPTARG
      ;;
    n)
      new_branch=$OPTARG 
      ;; 
    *)
      help
      exit      
  esac
done


if [ -z "$user_name" -o -z "$password" ]
then 
   echo "username and password must be provide..."
   exit 1
fi


repo_name_fun(){
  if [ -z $1 ]
  then 
    echo "repository name is empty, please provide with a valid repository name..."
    exit 1
  fi  
}

branch_name_fun(){
  if [ -z $1 ]
  then 
    echo "branch name is empty, please provide a branch name..."
    exit 1
  fi 
}

option_fun(){
  if [ -z $1 ]
  then 
    echo "option/operation not mentioned, please provide a valid operation to perform..."
    exit 1
  fi 
}

new_branch_fun(){
  if [ -z $1 ]
  then 
    echo "new branch to be created not mentioned, please provide a branch name..."
    exit 1
  fi 
}

destination_fun(){
  if [ -z $1 ]
  then 
    echo "destination or development branch not provided, please provide a valid destination branch name..."
    exit 1
  fi 
}

source_fun(){
  if [ -z $1 ]
  then 
    echo "source or production branch not provide, please provide a valid source branch name..."
    exit 1
  fi 
}

pull_chek_fun(){
  if [ -z $1 ]
  then 
    echo "pull number must be mention, if want to get the pull number, run listpull operation..."
    exit 1
  fi  
}

reference_branch_fun(){
  if [ -z $1 ]
  then 
    echo "refernce branch must be needed to create a branch..."
    exit 1
  fi 

}

#get status code

get_status_code(){
  test_url=$1
  status_code=$(curl -s -o /dev/null -w "%{http_code}" $test_url)
  #status_code=$(curl -s -I $test_url | awk '/HTTP/{print $2}')
  echo "status code :$status_code"
  if [ $status_code == 404 ]
  then 
    echo "wrong credentials passed, check once and try again..."
    exit 1 
  else
    return "$status_code"
  fi  
}



printing_list_of_repos(){
  username=$1
  password=$2
  base_url="-u $username:$password https://api.github.com/users/$username/repos"
  #for org: /orgs/:username/repos
  get_status_code "$base_url"
  status_code_returned=$?

  if [ $status_code_returned == 200 ]
  then 
     echo "following are the list of repositories:" 
     list_of_repos=$(curl -s $base_url | jq -r '.[].name')
     echo "$list_of_repos"
     exit 
     if [ "$list_of_repos" == "[]" ]
     then 
        echo "no repositories found..."
        exit 1  
     fi 
  elif [ $status_code_returned == 148 ]
  then
     echo "username is incorrect or not found..."
     exit 1
  fi         
}


#list of branches
printing_list_of_branches(){
  
  username=$1
  password=$2
  repository_name=$3
  repo_name_fun $3
  base_url="-u $username:$password https://api.github.com/repos/$username/$repository_name/branches"
  get_status_code "$base_url"
  status_code_returned=$?


  
  if [ $status_code_returned == 200 ]
  then
  list_of_branches=$(curl -s $base_url | jq . )
      if [ "$list_of_branches" == "[]" ]
      then
          echo "There are no branches available,this repository $repository_name is empty... "
          exit 1
      else 
          echo "the following are the list of branches available in $repository_name repository..." 
          echo "$list_of_branches" | jq -r '.[].name'
      fi    
  else
     echo "wrong username or repository name, please check and try again..."
  fi   
  exit
}




deleting_a_branch_fun(){
  #$user_name $password $repo_name $branch_name
  username=$1
  password=$2
  repository_name=$3
  branch_name=$4
  repo_name_fun $repository_name
  branch_name_fun $branch_name

  base_url="-u $username:$password -X DELETE https://api.github.com/repos/$username/$repository_name/git/refs/heads/$branch_name"
  get_status_code  "$base_url"
  deleted_branch_status_code=$?
  #echo "taken = $deleted_branch_status_code"

  if [ $deleted_branch_status_code == 204 ]
  then 
     echo "$branch_name deleted successfully..."
  elif [ $deleted_branch_status_code == 166 ] #422 mod 256
  then 
     echo "branch deletion un-successful, $branch_name branch not found..."      
  fi      
  exit
  }



listing_pull_requests_fun(){
  #$user_name $password $repo_name
  username=$1
  password=$2
  repository_name=$3
  repo_name_fun $repository_name
  #https://api.github.com/repos/octocat/hello-world/pulls
  base_url="-u $username:$password https://api.github.com/repos/$username/$repository_name/pulls?state=open" #?state=open 
  get_status_code "$base_url"
  listing_pull_requests_status_code=$?

   
  if [ $listing_pull_requests_status_code == 200 ]
  then 
    pull_requests=$(curl -s $base_url | jq .)
    #| jq '. | has(0)' == result =="true" == has a result
    if [ "$pull_requests" == "[]" ]
    then
       echo "pull_requests empty..."
    else
       echo "the following are the pull requests:"
       echo $pull_requests |  jq -r '.[] | "\(.title) '--pull_no--'  \(.number) '"--raised_by--"' \(.head.ref)"' #'--with_status--' \(.state)
    fi 
  elif [ $listing_pull_requests_status_code == 48 ] #304 mod  256
  then
       echo "Not modified..."
       exit 1
  elif [ $listing_pull_requests_status_code == 166 ] #422 mod 256
  then
       echo "Unprocessable Entity..."
       exit 1
  fi  
}  


closing_pull_requests_fun(){
  #$user_name $password $repo_name $pull_number
 
  username=$1
  password=$2
  repository_name=$3
  pull_no=$4
  repo_name_fun $repository_name
  pull_chek_fun $pull_no


  delete_pull_url="-u $username:$password -X PATCH https://api.github.com/repos/$username/$repository_name/pulls/$pull_no  "
  data_part='{"state":"closed"}'

  complete_url=""${delete_pull_url}" -d ${data_part}"

  get_status_code "$complete_url"
  close_pull_status_code=$?

  if [ $close_pull_status_code == 200 ]
  then 
     echo "The pull request status has been changed as follows..." 
     echo $(curl -s $complete_url | jq -r .'|" \(.title) '--with-pull_no--' \(.number) '--has_been--' \(.state)"' )
  elif [ $close_pull_status_code == 166 ]
  then 
     echo "validation failed...unproccessable entry..."
  else
     echo $close_pull_status_code
  fi   
}

merging_branches_fun(){
   #$user_name $password $repo_name $source $destination
  username=$1
  password=$2
  repository_name=$3
  source_branch=$4
  dest_branch=$5

  repo_name_fun $repository_name
  destination_fun $dest_branch
  source_fun $source_branch

  
  merge_branch_url="-u $username:$password -X POST https://api.github.com/repos/$user_name/$repository_name/merges "
  data_part='{"base":"'$source_branch'","head":"'$dest_branch'"}'
  
  complete_url=""${merge_branch_url}" -d "${data_part}""
  get_status_code "$complete_url"
  merge_branch_status_code=$?

  if [ $merge_branch_status_code == 204 ]
  then 
     echo "No content found..."
     exit 1
  elif [ $merge_branch_status_code == 201 ]
  then 
     echo "$dest_branch successfully merged into $source_branch" 
     #echo "$merging_branches" | jq .commit .message  
  elif [ $merge_branch_status_code == 147 ] #403 mod 256
  then 
     echo "forbidden..."
     exit 1
  elif [ $merge_branch_status_code == 153 ] #409 mod 256
  then 
     echo "conflicts found...."
     exit 1
  elif [ $merge_branch_status_code == 166 ]  #422 mod 256 
  then 
     echo "validation failed...unprocessable entity..."
     exit 1
  fi
}

cretaing_new_branch_fun(){
  #$user_name $password $repo_name $new_branch $user_name $password $repo_name $new_branch $reference_branch
  username=$1
  password=$2
  repository_name=$3
  new_branch_to_be_created=$4
  reference_branch_to_be_created=$5

  #echo "reference=$reference_branch_to_be_created"

  repo_name_fun $repository_name
  new_branch_fun $new_branch_to_be_created
  reference_branch_fun $reference_branch_to_be_created

  old_sha_value_url="-u $username:$password https://api.github.com/repos/$username/$repository_name/git/refs/heads/$reference_branch_to_be_created"
  get_status_code "$old_sha_value_url"
  sha_status_code_returned=$?


  if [ $sha_status_code_returned == 200 ]
  then 
     old_sha_value=$(curl -s $old_sha_value_url | jq -r '.object.sha')
     #echo "$old_sha_value" 
  elif [ $sha_status_code_returned == 153 ]  #409 mod 256
  then
      echo "The empty repo... cannot create branch, to create a branch atleast one branch should be already be created..."
      exit 1   
  else
     echo "received status code : $sha_status_code_returned" 
     exit 1      
  fi   
    
  #creating new by using previous sha vale

  new_branch_creating_url="-X POST -u $username:$password https://api.github.com/repos/$username/$repository_name/git/refs " 


  data_part='{"ref":"refs/heads/'$new_branch_to_be_created'","sha":"'${old_sha_value}'"}'
  complete_url=""${new_branch_creating_url}" -d "${data_part}""
  #echo "complete - $complete_url"

  get_status_code "$complete_url"
  new_branch_status_code=$?
  #echo "new branch status code ... $new_branch_status_code"
 
  if [ "$new_branch_status_code" == 201 ]
  then 
    new_branch_with_sha=$(curl -s $new_branch_creating_url)
    echo "$new_branch_to_be_created branch created successfully..."
    #echo "branch created successfully with the following sha value..."
    #echo $(curl -s "$complete_url" |  jq -r '.object.sha')

  elif [ "$new_branch_status_code" == 166 ]   #422 mod 256
  then
    echo "$new_branch_to_be_created branch already exists..."  
    exit 1
  fi
}
 

case $option in
       list_repo|repo_list)
            #list all the repos
            printing_list_of_repos $user_name $password
            ;;

       list_of_branches|branchlist)
            #list all the branches
            printing_list_of_branches $user_name $password $repo_name
            ;;
      
         
        delete_branch|del_branch) 
            #to delete a branch 
            
            deleting_a_branch_fun $user_name $password $repo_name $branch_name   
            ;;

        listpullreq|pr_list)
            #pull_requests
            listing_pull_requests_fun $user_name $password $repo_name  
            ;;

        close_pullreq)
            #delete a pull requests
            closing_pull_requests_fun $user_name $password $repo_name $pull_number
            ;;

        merge_branch|branch_merge)
            #merging branch
            merging_branches_fun $user_name $password $repo_name $source $destination                
            ;;

        create_branch|branch_create)
            #creating_new branch
            cretaing_new_branch_fun $user_name $password $repo_name $new_branch $source_reference_branch 
            ;;
        *)
            help

esac


