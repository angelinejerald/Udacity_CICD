stacks=$(aws cloudformation list-stacks --query "StackSummaries[*].StackName" --stack-status-filter CREATE_COMPLETE --no-paginate --output text)
AWS_PAGER="" aws cloudformation list-exports --query "Exports[?Name==\`WorkflowID\`].Value" --no-paginate --output text > newwfid.txt
new_wf_id=$(cat newwfid.txt)

for i in $stacks
do
echo $i | grep -v Cloudfront | grep -v $new_wf_id | awk -F '-' '{print $3}' >> ids.txt
done

cat ids.txt | sort -u >> oldstacks.txt

for stack in `cat oldstacks.txt`
do
echo "delete s3 $stack"
aws s3 rm "s3://udapeople-$stack" --recursive
echo "delete backend stack $stack"
aws cloudformation delete-stack --stack-name udapeople-backendStack-$stack
echo "delete frontend stack $stack"
aws cloudformation delete-stack --stack-name udapeople-frontendStack-$stack
done
