# Copyright (c) 2017-2021, Jan Cajthaml <jan.cajthaml@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ---------------------------------------------------------------------------- #
# stage 0 bootstrap dependencies

FROM amd64/debian:buster

COPY packaging/bin/* /opt/artifacts/

USER root

RUN apt-get update && \
    apt-get install -y \
      ca-certificates \
      gnupg2 \
      wget

RUN wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add && \
    echo "deb https://repos.influxdata.com/debian buster stable" | tee /etc/apt/sources.list.d/influxdb.list && \
    apt-get update

RUN apt-get install -y -f /opt/artifacts/metrics_0.0.0_amd64.deb

RUN mkdir -p /opt/metrics/data

# ---------------------------------------------------------------------------- #
# stage 1 link files

FROM amd64/debian:buster

COPY --from=0 /opt/artifacts/* /tmp/artifacts/
COPY --from=0 /usr/bin/telegraf /usr/bin/telegraf
COPY --from=0 /usr/lib/telegraf /usr/lib/telegraf
COPY --from=0 /etc/telegraf /etc/telegraf
COPY --from=0 /etc/metrics /etc/metrics
COPY --from=0 /opt/metrics /opt/metrics

ENTRYPOINT ["/usr/bin/telegraf", "--config", "/etc/metrics/conf.d/telegraf.conf"]
