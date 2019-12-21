import boto3

ACCESS_KEY = 'AKIAJWMM6BZHNNFUGRYA'  # insert your access key
SECRET_KEY = 'vJkkBrqJ4xrdHdpBjxXB6HEwVD1OIsauP4vmsADA'  # insert your AWS secret key here
STACK_NAME = 'AoogebraStack'


def createkeypair():
    ec2client = boto3.client('ec2', 'us-east-2', aws_access_key_id=ACCESS_KEY, aws_secret_access_key=SECRET_KEY);

    all_pairs = ec2client.describe_key_pairs()['KeyPairs']
    print(all_pairs)
    if all_pairs == []:
        priv = ec2client.create_key_pair(KeyName='DBKeyPair')
        print("priv", priv)
        return

    for pair in all_pairs:

        if pair['KeyName'] != 'DBKeyPair':
            priv = ec2client.create_key_pair(KeyName='DBKeyPair')
            print("priv", priv)

        else:
            return


def deletestack(client):
    client.delete_stack(StackName=STACK_NAME)


def createstack(client):
    client.create_stack(StackName=STACK_NAME,
                        TemplateURL='https://aoogebradatabasesetup.s3-ap-southeast-1.amazonaws.com/databasesetup.json',
                        Parameters=[{'ParameterKey': 'KeyPair', 'ParameterValue': 'DBKeyPair'}, ])


client = boto3.client('cloudformation', 'us-east-2', aws_access_key_id=ACCESS_KEY, aws_secret_access_key=SECRET_KEY)
# deletestack(client)
createkeypair()
createstack(client)

waiter = client.get_waiter('stack_create_complete')

waiter.wait(
    StackName='AoogebraStack',
    WaiterConfig={
        'Delay': 30,
        'MaxAttempts': 123
    }
)

exports = {exportdict['Name']: exportdict['Value'] for exportdict in client.list_exports()['Exports']}
print(exports)
envfile = './envfile.txt'
backendpublicdns = exports['FlaskPublicIP']
mongopublicdns = exports['MongoPublicIP']
mysqlpublicdns = exports['MySQLPublicIP']


with open(envfile, "w", encoding="utf8") as f:
    f.write('{} {} \n'.format('Backend', backendpublicdns))
    f.write('{} {} \n'.format('Mongo', mongopublicdns))
    f.write('{} {} \n'.format('MySQL', mysqlpublicdns))
f.close()


# The following code can only be used AFTER the stack is created
# exports = {exportdict['Name']: exportdict['Value'] for exportdict in client.list_exports()['Exports']}
# print(exports)
# envfile = './envfile.txt'
# backendpublicdns = exports['FlaskPublicIP']
# mongopublicdns = exports['MongoPublicIP']
# mysqlpublicdns = exports['MySQLPublicIP']
# with open(envfile, "w", encoding="utf8") as f:
#     f.write('{} {} \n'.format('Backend', backendpublicdns))
#     f.write('{} {} \n'.format('Mongo', mongopublicdns))
#     f.write('{} {} \n'.format('MySQL', mysqlpublicdns))
# f.close()
