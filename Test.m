% Copyright 2017 Google Inc.
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     https://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

function Test(project_name)

params = LoadProjectParams(project_name);
load(params.output_model_filename, 'model')

data = PrecomputeMixedData(...
  params.TRAINING.CROSSVALIDATION_DATA_FOLDER, ...
  params.TRAINING.EXTRA_TRAINING_DATA_FOLDERS, ...
  params.TRAINING.EXTRA_TESTING_DATA_FOLDERS, params);

avgErr = 0;

for i_data = 1:length(data)
  [state_obs] = EvaluateModel(model.F_fft, model.B, data(i_data).X, fft2(data(i_data).X), [], [], [], params);
  rgb_gt = data(i_data).gt_rgb;
  rgb_est = UvToRgb(state_obs.mu);
  
  curErr = colorangle(rgb_gt, rgb_est);
  avgErr = avgErr + curErr;
  
  [~,filename,~] = fileparts(data(i_data).filename);
  disp(['{ ', '"', filename, '", { ',   ...
      num2str(rgb_est(1), 8), ', '      ...
      num2str(rgb_est(2), 8), ', '      ...
      num2str(rgb_est(3), 8), ' } },'   ...
      ]);
%   disp(['Error: ', num2str(curErr,2), ' degrees']);
end

avgErr = avgErr / length(data);
disp(['Average error: ', num2str(avgErr, 2), ' degrees']);