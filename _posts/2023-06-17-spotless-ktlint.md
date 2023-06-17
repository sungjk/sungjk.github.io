---
layout: entry
post-category: kotlin
title: Kotlin 코드 컨벤션 맞추기(feat. Spotless)
author: 김성중
author-email: ajax0615@gmail.com
description: Spotless를 이용해서 코틀린 코드 컨벤션 맞추기
keywords: kotlin, spotless, ktlint, coding convention
publish: true
---

유지보수성, 결합도, 응집도 등의 특성들이 소프트웨어의 품질을 향상시키기 위한 전략이라고 한다면, 코드 품질을 개선하기 위한 전략으로는 코드 리뷰, 정적 분석, 코딩 컨벤션 등이 있다. 이 중에서도 정적 분석과 코딩 컨벤션을 도와주는 도구가 바로 Lint다.

Lint는 Linter라고도 부르는데 [위키피디아](https://en.wikipedia.org/wiki/Lint_(software))에서는 다음과 같이 정의하고 있다.

> Lint, or a linter, is a static code analysis tool used to flag programming errors, bugs, stylistic errors and suspicious constructs. The term originates from a Unix utility that examined C language source code.

Linting이 코드에서 발생할 수 있는 에러를 줄여줄 수도 있지만, 코드의 전반적인 품질을 향상시키기 위한 목적이 가장 크다. 어떤 포맷에 맞춰서 개발해야 할지 고민이 될 때, Lint는 그 가이드를 제공해주고 이에 맞춰서 개발을 더 가속화하고 비용을 절감할 수 있는 효과도 누릴 수 있다. 다만 처음엔 Lint가 제안하는 코드 스타일에 적응하느라 더 많은 시간이 필요할 수도 있다.

# Ktlint
[Ktlint](https://github.com/pinterest/ktlint)는 [Pinterest](https://www.pinterest.co.kr/)에서 만든 코틀린 전용 Linter다. 주요 특징으로는 따로 설정이 필요 없어서 적용하기 쉽고, [코틀린 공식 코드 스타일](https://kotlinlang.org/docs/reference/coding-conventions.html)을 따르고 있으며, 내장된 포맷터(Built-in formatter)가 있어서 코드 스타일을 손으로 직접 고칠 필요가 없다.

Scala 개발할 때에는 주로 scalastyle이나 scalafix를 사용했었고, Java로 개발할 때에는 Checkstyle만 써봤었는데, 이것들에 비하면 ktlint는 적용하기가 너무 쉽고 포맷터도 제공하고 있어서 만족도가 너무 좋았다. 사실 코틀린의 공식 컨벤션이 내가 주로 작성하는 코드 스타일과 비슷해서, 코틀린 공식 코드 스타일을 따르는 ktlint가 나랑 더 잘맞는 느낌이 들기도 했다.

## Official Code Style
Intellij IDEA를 사용하고 있다면, 프로젝트의 루트 디렉터리에 gradle.properties 파일 안에 아래 설정값을 입력하면 코드 스타일을 코틀린 공식 컨벤션을 따르겠다고 설정할 수 있다. 자세한 내용은 [여기](https://kotlinlang.org/docs/code-style-migration-guide.html#in-gradle)에서 확인할 수 있다.

```bash
// gradle.properties
kotlin.code.style=official
```

## ktlint-gradle 플러그인 사용해서 Ktlint 적용하기
Gradle 팀 사람이 개인적으로 만든것 같은데, [ktlint-gradle](https://github.com/jlleitschuh/ktlint-gradle) 플러그인을 추가하면 gradle에서 ktlint를 쉽게 적용할 수 있다. Gradle 설정 파일(build.gradle.kts) 안에 아래 플러그인을 추가하면 된다.

```bash
plugins {
    ...
    id("org.jlleitschuh.gradle.ktlint") version "10.3.0"
    id("org.jlleitschuh.gradle.ktlint-idea") version "10.3.0"
}

subprojects {
    ...
    apply(plugin = "org.jlleitschuh.gradle.ktlint")
    apply(plugin = "org.jlleitschuh.gradle.ktlint-idea")
    ...
}
```

다음으로는 프로젝트 루트 디렉터리에 `.editorconfig` 파일 생성하고, 아래 설정값 입력한다. [EditorConfig](https://github.com/pinterest/ktlint#editorconfig)는 어떤 규칙에 따라서 Linting을 할건지 ktlint에게 알려주는 속성값이라고 생각하면 된다. 디폴트값은 README를 참고하면 잘 소개되어 있는데, 나는 yaml 설정과 trailing 설정도 추가할 수 있어서 몇가지 더 추가해서 사용하고 있다.

```bash
root = true

[*]
charset = utf-8
insert_final_newline = true
trim_trailing_whitespace = true

[*.{kt,kts}]
indent_size = 4

[*.{yml,yaml}]
indent_size = 2
```

아래 명령어를 실행하면 해당 프로젝트에 작성된 코드를 기반으로 스타일을 검사하고, 코드를 스타일에 맞게 리포맷팅할 수 있다.

```bash
# 스타일 검사
$ ./gradlew ktlintCheck

# 스타일 포맷팅
$ ./gradlew ktlintFormat
```

## Spotless 사용해서 Ktlint 적용하기
Spotless는 Kotlin 뿐만 아니라 Java, Groovy, Json, Markdown 등 다양한 언어와 포맷들의 일관된 포맷팅을 지원하는 툴이다. Kotlin도 ktlint 뿐만 아니라 detekt, ktfmt, diktat 등 다양한 린터들이 있는데, Spotless는 이중에서 ktlint, ktfmt, diktat를 이용해서 Kotlin 포맷팅을 지원한다. 그래서 ktlint-plugin만 단독으로 사용하는 것보다 코틀린 이외에 프로젝트 전체적인 포맷팅을 하고 싶다면 Spotless는 정말 좋은 툴이라고 생각한다.

```groovy
plugins {
    id "com.diffplug.spotless" version "6.13.0"
}

spotless {
    java {
        target "**/*.java"
        targetExclude "$buildDir/**/*.java"
        targetExclude "bin/**/*.java"
        removeUnusedImports()
    }
    kotlin {
        target "**/*.kt"
        targetExclude "$buildDir/**/*.kt"
        targetExclude "bin/**/*.kt"
        ktlint("0.49.1")
            .editorConfigOverride([
                charset                                    : "utf-8",
                end_of_line                                : "lf",
                insert_final_newline                       : true,
                indent_style                               : "space",
                indent_size                                : 4,
                max_line_length                            : 120,
                trim_trailing_whitespace                   : true,
                ij_kotlin_allow_trailing_comma             : true,
                ij_kotlin_allow_trailing_comma_on_call_site: true,
            ])
    }
    format 'xml', {
        target "src/**/*.xml"
        eclipseWtp('xml')
        eclipseWtp('xml', '11.0')
    } 
    json {
        target "src/**/*.json"
        simple()
    }
    format 'misc', {
        target "*.gradle", "*.md", ".gitignore"
        trimTrailingWhitespace()
        indentWithTabs()
        endWithNewline()
    }
}
```

아래 명령어를 실행하면 해당 프로젝트에 작성된 코드를 기반으로 스타일을 검사하고, 코드를 스타일에 맞게 리포맷팅할 수 있다.

```bash
# 전체 스타일 검사
$ ./gradlew spotlessCheck

# 코틀린 스타일 검사
$ ./gradlew spotlessKotlinCheck

# 전체 스타일 자동 포맷팅
$ ./gradlew spotlessApply

# 코틀린 스타일 자동 포맷팅
$ ./gradlew spotlessKotlinApply
```

자세한 설정은 [Spotless plugin for Gradle](https://github.com/diffplug/spotless/blob/main/plugin-gradle/README.md#-spotless-plugin-for-gradle)에서 확인할 수 있다.

# Commit hook 설정하기
빌드 단계에 포맷 체크를 추가해두면 항상 일관된 포맷이 유지되어서 좋지만, 포맷에 어긋난 코드가 Git Remote 저장소에 올라가면 CI 단계에서 빌드에 실패하고 다시 수정하고 빌드를 다시 해야 하는 불편함이 생긴다. 그래서 로컬에서 커밋을 만들기 전에 Check를 스타일 체크를 미리 하는 Commit PreHook을 등록해두면 이런 불편함을 조금이라도 해소할 수 있다. 

Gradle에 아래처럼 createSpotlessPreCommitHook task를 등록해두고, 로컬에서 `./gradlew createSpotlessPreCommitHook` 명령어를 실행하면 pre-commit hook이 등록된다. 아래 pre-commit hook은 커밋 전에 spotlessApply task를 실행해서 전체 코드 스타일을 자동으로 포맷팅하는 역할을 한다.

```groovy
tasks.register('createSpotlessPreCommitHook') {
    def gitHooksDirectory = new File("$project.rootDir/.git/hooks/")
    if (!gitHooksDirectory.exists()) {
        gitHooksDirectory.mkdirs()
    }
    new File("$project.rootDir/.git/hooks", "pre-commit").text =
            """#!/bin/bash
echo "Running spotless check"
./gradlew spotlessApply
if [ \$? -eq 0 ]
then
    echo "Spotless check succeed"
else
    echo "Spotless check failed" >&2
exit 1
fi
"""
    "chmod +x .git/hooks/pre-commit".execute()
}
```

여러 사람이 함께 개발을 하다 보면 서로의 코드 스타일이 달라서 리뷰에서도 많은 이야기가 오고 갈 때가 많은데, lint를 적용하고 나면 모두가 하나의 가이드에 맞춰서 개발하다 보니 리뷰에서 코드 스타일에 대한 이야기를 많이 줄일 수 있다. 마찬가지로 새로운 사람이 프로젝트에 합류하더라도 잘 적용된 lint가 있다면 어렵지 않게 스타일을 따라갈 수 있는 장점이 있다.

---

# 참고
- [spotless](https://github.com/diffplug/spotless)
- [ktlint](https://github.com/pinterest/ktlint)
- [ktlint-gradle](https://github.com/jlleitschuh/ktlint-gradle)
- [Kotlin Coding conventions](https://kotlinlang.org/docs/coding-conventions.html)
