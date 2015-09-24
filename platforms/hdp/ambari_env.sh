# Copyright 2014 Google Inc. All Rights Reserved.
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


# ambari_env.sh
#
# Extension providing a cluster with Apache Ambari installed and automatically
# provisions and configures the cluster's software. This installs and configures
# the GCS connector.

########################################################################
## There should be nothing to edit here, use ambari.conf              ##
########################################################################

# Import the base Ambari installation
import_env platforms/hdp/ambari_manual_env.sh

# The distribution to install on your cluster.
AMBARI_STACK="${AMBARI_STACK:-HDP}"
AMBARI_STACK_VERSION="${AMBARI_STACK_VERSION:-2.2}"

## The components of that distribution to install on the cluster.
# Default is all but Apache Knox.
AMBARI_SERVICES="${AMBARI_SERVICES:-FALCON FLUME GANGLIA HBASE HDFS HIVE KAFKA
    KERBEROS MAPREDUCE2 NAGIOS OOZIE PIG SLIDER SQOOP STORM TEZ YARN ZOOKEEPER}"


if [[ -n "${BDUTIL_DIR}" ]]; then
  UPLOAD_FILES+=(
    "${BDUTIL_DIR}/platforms/hdp/create_blueprint.py"
  )
fi

COMMAND_GROUPS+=(
  "install-ambari-components:
     platforms/hdp/install_ambari_components.sh
  "
  
  "install-spatialhadoop2:
    platforms/hdp/install_spatialhadoop2.sh
  "
  
  "download_pig_libs:
    platforms/hdp/download_pig_libs.sh
  "
)

COMMAND_STEPS+=(
  'install-ambari-components,*'
  'install-gcs-connector-on-ambari,install-gcs-connector-on-ambari'
  'update-ambari-config,*'
  'install-spatialhadoop2,install-spatialhadoop2'
  'download_pig_libs,*'
)
