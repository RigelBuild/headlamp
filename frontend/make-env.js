/*
 * Copyright 2025 The Kubernetes Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
// Creates the .env file
import { execSync } from 'child_process';
import fs from 'fs';
const appInfo = JSON.parse(fs.readFileSync('../app/package.json', 'utf8'));

// Prefer the build-time value (set by the container build, where there is no
// .git directory). Fall back to asking git for local dev builds, and to
// "unknown" when neither is available.
function gitVersion() {
  const fromEnv = process.env.HEADLAMP_GIT_VERSION;
  if (fromEnv) {
    return fromEnv.trim();
  }
  try {
    return execSync('git rev-parse HEAD', { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim();
  } catch {
    return 'unknown';
  }
}

const envContents = {
  REACT_APP_HEADLAMP_VERSION: appInfo.version,
  REACT_APP_HEADLAMP_GIT_VERSION: gitVersion(),
  REACT_APP_HEADLAMP_PRODUCT_NAME: appInfo.productName,
  REACT_APP_ENABLE_REACT_QUERY_DEVTOOLS: 'false',
  REACT_APP_HEADLAMP_SIDEBAR_DEFAULT_OPEN: 'true'
};

function createEnvText() {
  let text = '';
  Object.entries(envContents).forEach(([key, value]) => {
    text += `${key}=${value}\n`;
  });

  return text;
}

const fileName = process.argv[2] || '.env';

fs.writeFileSync(fileName, createEnvText());
