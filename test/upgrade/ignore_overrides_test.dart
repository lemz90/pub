// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';

main() {
  test("--ignore-overrides correctly ignores 'dependency_overrides'", () async {
    await servePackages((builder) {
      builder.serve("foo", "1.0.0");
      builder.serve("foo", "2.0.0");
    });

    await d.dir(appPath, [
      d.pubspec({
        "name": "myapp",
        "version": "1.0.0",
        "dependencies": {"foo": "1.0.0"},
        "dependency_overrides": {"foo": "2.0.0"}
      })
    ]).create();

    await pubGet();
    await d.appPackagesFile({"foo": "2.0.0"}).validate();

    await pubUpgrade(
        args: ["--ignore-overrides"],
        output: allOf([
          contains("Ignoring 'dependency_overrides'."),
          contains("< foo 1.0.0 (was 2.0.0) (2.0.0 available)"),
          contains("Downloading foo 1.0.0..."),
          contains("Changed 1 dependency!")
        ]));

    await d.appPackagesFile({"foo": "1.0.0"}).validate();
  });
}