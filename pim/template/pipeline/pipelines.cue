package pipelines

import (
	"{{ .Values.cue.package }}/charts/directory:directories"
	"{{ .Values.cue.package }}/charts/pipeline/resolvers"
	"github.com/tailor-inc/platform-core-services/api/gen/go/pipeline/v1:pipelinev1"
)

pipeline: pipelinev1.#Manifests & {
	namespace:   {{ .Values.pipeline.namespace | quote }}
	invoker:     directories.roleMap.Admin.id
	description: "PIM pipeline resolver"
	resolverMap: {
		"addBrand":            resolvers.addBrand
		"addBrandUser":        resolvers.addBrandUser
		"addBrandProduct":  resolvers.addBrandProduct
	}
}
