# Copyright 2013 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file contains environment-variable overrides to be used in conjunction
# with bdutil_env.sh in order to deploy a single-node Hadoop cluster.
# Usage: ./bdutil deploy -e single_node_env.sh

NUM_WORKERS=1

# A single-node setup is much more likely to be used for development, so install
# JDK with compiler/tools instead of just the minimal JRE.
INSTALL_JDK_DEVEL=true

# Save away the base evaluate_late_variable_bindings function so we can
# override it.
copy_func evaluate_late_variable_bindings old_evaluate_late_variable_bindings

function evaluate_late_variable_bindings() {
  # Stash away the old value here so we can differentiate between whether the
  # user overrides set it or we just resolved it in the base implementation
  # of evaluate_late_variable_bindings.
  local old_nfs_master_hostname="${GCS_CACHE_MASTER_HOSTNAME}"

  old_evaluate_late_variable_bindings

  # In the case of the single-node cluster, we'll just use the whole PREFIX
  # as the name of the master and worker.
  WORKERS[0]=${PREFIX}
  MASTER_HOSTNAME=${PREFIX}
  WORKER_ATTACHED_PDS[0]="${PREFIX}-pd"
  MASTER_ATTACHED_PD="${PREFIX}-pd"

  # Fully qualified HDFS URI of namenode
  NAMENODE_URI="hdfs://${MASTER_HOSTNAME}:8020/"

  # Host and port of jobtracker
  JOB_TRACKER_URI="${MASTER_HOSTNAME}:9101"

  # GCS directory for deployment-related temporary files.
  local staging_dir_base="gs://${CONFIGBUCKET}/bdutil-staging"
  BDUTIL_GCS_STAGING_DIR="${staging_dir_base}/${MASTER_HOSTNAME}"

  # Default NFS cache host is the master node, but it can be overriden to point
  # at an NFS server off-cluster.
  if [[ -z "${old_nfs_master_hostname}" ]]; then
    GCS_CACHE_MASTER_HOSTNAME="${MASTER_HOSTNAME}"
  fi

  # Since $WORKERS and $MASTER_HOSTNAME both refer to the same single-node
  # VM, we must override COMMAND_STEPS to prevent duplicating steps. We also
  # omit deploy-ssh-worker-setup because there is no need to copy SSH keys to
  # the localhost.
  COMMAND_STEPS=(${COMMAND_STEPS[@]/,*/,*})
}
