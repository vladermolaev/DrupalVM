#!/bin/bash
pushd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
source util.sh
VM_NAME_DEFAULT=WEB
HOST_FOLDER_DEFAULT="$HOME/repos"
GUEST_FOLDER_DEFAULT="/share"
SSH_CONFIG_PATH=$HOME/.ssh/config
read -rp "Enter unique VM name [${VM_NAME_DEFAULT}]: " VM_NAME
VM_NAME=${VM_NAME:-${VM_NAME_DEFAULT}}
VM_NAME=${VM_NAME// /_}
VAGRANT_VM_PATH=$HOME/Vagrant/${VM_NAME}
if [[ -d $VAGRANT_VM_PATH ]]; then
    echo "$VAGRANT_VM_PATH exists. Select a unique VM name."
    exit 1
fi
mkdir -p "$VAGRANT_VM_PATH"
sed "s/<my_vm_name>/${VM_NAME}/g" Vagrantfile-template > "$VAGRANT_VM_PATH"/Vagrantfile
read -rp "Enter path of the host OS folder you want to share with the VM, [${HOST_FOLDER_DEFAULT}]: " HOST_FOLDER
HOST_FOLDER=${HOST_FOLDER:-${HOST_FOLDER_DEFAULT}}
eval HOST_FOLDER="${HOST_FOLDER}"
if [[ "$OSTYPE" == "msys" ]]; then
    # On Windows replace "/c/User/..." with "c:/User/..."
    HOST_FOLDER=$(echo "${HOST_FOLDER}" | sed 's/^\/\(.\)\//\1:\//')
fi
echo "Host folder: $HOST_FOLDER"
read -rp "Enter absolute path of the guest OS folder to mount the shared folder to, [${GUEST_FOLDER_DEFAULT}]: " GUEST_FOLDER
GUEST_FOLDER=${GUEST_FOLDER:-${GUEST_FOLDER_DEFAULT}}
echo "Guest folder: $GUEST_FOLDER"
sed "/export ARTIFACT_REPO_PASS=/ s/$/${ARTIFACT_REPO_PASS}/" bashrc-exports > "$VAGRANT_VM_PATH"/bashrc-exports
echo "cd $GUEST_FOLDER" >> "$VAGRANT_VM_PATH"/bashrc-exports
cp bashrc-aliases bashrc-functions ./nginx.conf-template ./*.sh "$VAGRANT_VM_PATH"
pushd "$VAGRANT_VM_PATH" || exit 1
case $(sed --help 2>&1) in
  *GNU*) sed_i () { sed -i "$@"; };;
  *) sed_i () { sed -i '' "$@"; };;
esac
sed_i "s|config\.vm\.synced_folder.*|config\.vm\.synced_folder \"${HOST_FOLDER}\", \"${GUEST_FOLDER}\"|g" Vagrantfile
if ! vagrant plugin list | grep -q vagrant-timezone; then
    vagrant plugin install vagrant-timezone
fi
vagrant up || exit
if ! grep -q "^Host ${VM_NAME}$" "${SSH_CONFIG_PATH}"; then
    # vagrant ssh-config | \
	#  sed "s/Host default/Host ${VM_NAME}/" | \
	#  sed "s/User vagrant/User root/" >> "${SSH_CONFIG_PATH}"
    vagrant ssh-config | \
     sed "s/Host default/Host ${VM_NAME}/" >> "${SSH_CONFIG_PATH}"
    echo "Entry \"Host ${VM_NAME}\" added to ${SSH_CONFIG_PATH}"
fi
ALIAS_BODY="alias start${VM_NAME}=\"pushd $HOME/Vagrant/${VM_NAME} && vagrant up && popd\""
AddShellAlias "$ALIAS_BODY"
echo "Finished setting up $VM_NAME. You can use either of these two commands to log in to it:"
echo " $ ssh ${VM_NAME}"
echo " $ cd $VAGRANT_VM_PATH && vagrant ssh"
popd || exit
