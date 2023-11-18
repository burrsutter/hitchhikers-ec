package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in

deny contains result if {
	expected := "NOT /opt/jboss/container/java/run/run-java.sh"
	got := input.image.config.Entrypoint[0]

	expected != got

	result := {
		"code": "zero_to_hero.entrypoint",
		"msg": sprintf("entrypoint %q is not expected, %q", [got, expected]),
	}
}
