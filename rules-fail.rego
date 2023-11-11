package mypackage

import future.keywords.contains
import future.keywords.if
import future.keywords.in


# METADATA
# title: Builder ID
# description: Verify the SLSA Provenance has the builder.id set to
#   the expected value.
# custom:
#   short_name: builder_id
#   failure_msg: The builder ID %q is not the expected %q
#   solution: >-
#     Ensure the correct build system was used to build the container
#     image.
deny contains result if {
	some attestation in input.attestations
	attestation.statement.predicateType == "https://slsa.dev/provenance/v0.2"

	expected := "https://anotherhost/another-dummy-id"
	received := attestation.statement.predicate.builder.id

	expected != received

	result := {
		"code": "mystuff.builder_id",
		"msg": sprintf("The builder ID %q is NOT invalid, expected %q", [received, expected])
	}
}
