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

const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');
const { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync } = require('fs');

const envFile = path.join(os.tmpdir(), 'tmpEnv');

test('Create & verify', () => {
  const execFile = path.resolve(path.join(__dirname, '..', 'make-env.js'));
  execFileSync('node', [execFile, envFile]);

  const envContents = readFileSync(envFile).toString();

  const lines = envContents.split(/\r?\n/);
  const envObj = {};

  lines.forEach(line => {
    // Skip empty lines
    if (!line) {
      return;
    }

    const [key, val] = line.trim().split('=');

    expect(key.trim()).toBeDefined();
    expect(val.trim()).toBeDefined();

    envObj[key] = val;
  });

  const keys = Object.keys(envObj);
  expect(keys).toContain('REACT_APP_HEADLAMP_VERSION');
  expect(keys).toContain('REACT_APP_HEADLAMP_GIT_VERSION');
  expect(keys).toContain('REACT_APP_HEADLAMP_PRODUCT_NAME');
});

test('uses HEADLAMP_GIT_VERSION when it is set', () => {
  const execFile = path.resolve(path.join(__dirname, '..', 'make-env.js'));
  execFileSync('node', [execFile, envFile], {
    env: { ...process.env, HEADLAMP_GIT_VERSION: 'abc123def456' },
  });

  const envContents = readFileSync(envFile).toString();
  expect(envContents).toContain('REACT_APP_HEADLAMP_GIT_VERSION=abc123def456\n');
});

test('falls back to unknown when git cannot report a version', () => {
  const execFile = path.resolve(path.join(__dirname, '..', 'make-env.js'));
  // A directory with no .git above it, so `git rev-parse HEAD` fails.
  const noGitDir = mkdtempSync(path.join(os.tmpdir(), 'make-env-nogit-'));
  mkdirSync(path.join(noGitDir, 'frontend'));
  mkdirSync(path.join(noGitDir, 'app'));
  copyFileSync(execFile, path.join(noGitDir, 'frontend', 'make-env.js'));
  copyFileSync(
    path.join(__dirname, '..', '..', 'app', 'package.json'),
    path.join(noGitDir, 'app', 'package.json')
  );
  const env = { ...process.env };
  delete env.HEADLAMP_GIT_VERSION;
  execFileSync('node', [path.join(noGitDir, 'frontend', 'make-env.js'), envFile], {
    cwd: path.join(noGitDir, 'frontend'),
    env: { ...env, GIT_CEILING_DIRECTORIES: noGitDir },
  });

  const envContents = readFileSync(envFile).toString();
  expect(envContents).toContain('REACT_APP_HEADLAMP_GIT_VERSION=unknown\n');
  rmSync(noGitDir, { recursive: true, force: true });
});
