#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from django.conf.urls.defaults import url, patterns


urlpatterns = patterns('filebrowser.views',
  # Base view
  url(r'^$', 'index', name='index'),

  url(r'listdir(?P<path>/.*)', 'listdir', name='listdir'),
  url(r'display(?P<path>/.*)', 'display', name='display'),
  url(r'stat(?P<path>/.*)', 'stat', name='stat'),
  url(r'download(?P<path>/.*)', 'download', name='download'),
  url(r'status', 'status', name='status'),
  # Catch-all for viewing a file (display) or a directory (listdir)
  url(r'view(?P<path>/.*)', 'view', name='view'),
  url(r'chooser(?P<path>/.*)', 'chooser', name='view'),
  url(r'edit(?P<path>/.*)', 'edit', name='edit'),
  url(r'save', 'save_file'),

  # POST operations
  url(r'upload_flash$', 'upload_flash', name='upload_flash'),
  url(r'upload$', 'upload', name='upload'),
  url(r'rename', 'rename', name='rename'),
  url(r'mkdir', 'mkdir', name='mkdir'),
  url(r'^move', 'move', name='move'),
  url(r'remove', 'remove', name='remove'),
  url(r'rmdir', 'rmdir', name='rmdir'),
  url(r'rmtree', 'rmtree', name='rmtree'),
  url(r'chmod', 'chmod', name='chmod'),
  url(r'chown', 'chown', name='chown'),
)