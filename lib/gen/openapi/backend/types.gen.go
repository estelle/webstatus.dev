// Package backend provides primitives to interact with the openapi HTTP API.
//
// Code generated by github.com/deepmap/oapi-codegen version v1.15.0 DO NOT EDIT.
package backend

// BasicErrorModel defines model for BasicErrorModel.
type BasicErrorModel struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

// Feature defines model for Feature.
type Feature struct {
	FeatureId string    `json:"feature_id"`
	Spec      *[]string `json:"spec,omitempty"`
}

// FeaturePage defines model for FeaturePage.
type FeaturePage struct {
	Data     []Feature     `json:"data"`
	Metadata *PageMetadata `json:"metadata,omitempty"`
}

// PageMetadata defines model for PageMetadata.
type PageMetadata struct {
	NextPageToken *string `json:"next_page_token,omitempty"`
}

// PaginationSizeParam defines model for paginationSizeParam.
type PaginationSizeParam = int

// PaginationTokenParam defines model for paginationTokenParam.
type PaginationTokenParam = string

// GetV1FeaturesParams defines parameters for GetV1Features.
type GetV1FeaturesParams struct {
	// PageToken Pagination token
	PageToken *PaginationTokenParam `form:"page_token,omitempty" json:"page_token,omitempty"`

	// PageSize Number of results to return
	PageSize *PaginationSizeParam `form:"page_size,omitempty" json:"page_size,omitempty"`

	// BaselineStartYear Start range (inclusive) for when features became part of baseline
	BaselineStartYear *int `form:"baseline_start_year,omitempty" json:"baseline_start_year,omitempty"`

	// BaselineEndYear End range (inclusive) for when features became part of baseline
	BaselineEndYear *int `form:"baseline_end_year,omitempty" json:"baseline_end_year,omitempty"`
}