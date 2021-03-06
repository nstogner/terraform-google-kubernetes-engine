# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

project_id = attribute('project_id')
location = attribute('location')
cluster_name = attribute('cluster_name')

credentials_path = attribute('credentials_path')
ENV['CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE'] = credentials_path

control "gcloud" do
  title "Google Compute Engine GKE configuration"
  describe command("gcloud --project=#{project_id} container clusters --zone=#{location} describe #{cluster_name} --format=json") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq '' }

    let!(:data) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout)
      else
        {}
      end
    end

    describe "node pools" do
      let(:node_pools) { data['nodePools'].reject { |p| p['name'] == "default-pool" } }

      it "has 2" do
        expect(node_pools.count).to eq 2
      end

      describe "pool-01" do
        it "exists" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
            )
          )
        end

        it "is the expected machine type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "machineType" => "n1-standard-2",
              ),
            )
          )
        end

        it "has autoscaling enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "autoscaling" => including(
                "enabled" => true,
              ),
            )
          )
        end

        it "has the expected minimum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "autoscaling" => including(
                "minNodeCount" => 1,
              ),
            )
          )
        end

        it "has autorepair enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "management" => including(
                "autoRepair" => true,
              ),
            )
          )
        end

        it "has automatic upgrades enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "management" => including(
                "autoUpgrade" => true,
              ),
            )
          )
        end

        it "has the expected labels" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "labels" => {
                  "all-pools-example" => "true",
                  "pool-01-example" => "true",
                  "cluster_name" => cluster_name,
                  "node_pool" => "pool-01",
                },
              ),
            )
          )
        end

        it "has the expected network tags" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-01",
              "config" => including(
                "tags" => match_array([
                  "all-node-example",
                  "pool-01-example",
                  "gke-#{cluster_name}",
                  "gke-#{cluster_name}-pool-01",
                ]),
              ),
            )
          )
        end
      end

      describe "pool-02" do
        it "exists" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
            )
          )
        end

        it "is the expected machine type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "machineType" => "n1-standard-2",
              ),
            )
          )
        end

        it "has autoscaling enabled" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "autoscaling" => including(
                "enabled" => true,
              ),
            )
          )
        end

        it "has the expected minimum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "autoscaling" => including(
                "minNodeCount" => 1,
              ),
            )
          )
        end

        it "has the expected maximum node count" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "autoscaling" => including(
                "maxNodeCount" => 2,
              ),
            )
          )
        end

        it "has the expected disk size" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "diskSizeGb" => 30,
              ),
            )
          )
        end

        it "has the expected disk type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "diskType" => "pd-standard",
              ),
            )
          )
        end

        it "has the expected image type" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "imageType" => "COS",
              ),
            )
          )
        end

        it "has the expected labels" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "labels" => including(
                  "all-pools-example" => "true",
                  "cluster_name" => cluster_name,
                  "node_pool" => "pool-02",
                )
              ),
            )
          )
        end

        it "has the expected network tags" do
          expect(data['nodePools']).to include(
            including(
              "name" => "pool-02",
              "config" => including(
                "tags" => match_array([
                  "all-node-example",
                  "gke-#{cluster_name}",
                  "gke-#{cluster_name}-pool-02",
                ])
              ),
            )
          )
        end
      end
    end
  end
end
