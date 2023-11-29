package permissions

import (
	"github.com/tailor-inc/platform-core-services/cmd/tailorctl/schema/v1:tailordb"
)

#AllowEveryone: {
	create: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
	read: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
	update: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
	delete: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
	admin: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
}

// Disable update/delete/admin by anyone
#ReadonlyEveryone: {
	create: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
	read: [
		{id: tailordb.#Everyone, permit: tailordb.#Allow},
	]
	update: []
	delete: []
	admin: []
}
