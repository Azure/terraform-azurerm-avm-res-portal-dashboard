{
    "lenses": {
        "0": {
            "order": 0,
            "parts": {
                "0": {
                    "position": {
                        "colSpan": 6,
                        "rowSpan": 4,
                        "x": 0,
                        "y": 0
                    },
                    "metadata": {
                        "inputs": [],
                        "type": "Extension/HubsExtension/PartType/MarkdownPart",
                        "settings": {
                            "content": {
                                "settings": {
                                    "content": ${markdown_content},
                                    "subtitle": "${dashboard_subtitle}",
                                    "title": "${dashboard_title}"
                                }
                            }
                        }
                    }
                },
                "1": {
                    "position": {
                        "colSpan": 7,
                        "rowSpan": 4,
                        "x": 6,
                        "y": 0
                    },
                    "metadata": {
                        "inputs": [
                            {
                                "name": "resourceType",
                                "value": "Microsoft.Resources/resources",
                                "isOptional": true
                            },
                            {
                                "name": "filter",
                                "isOptional": true
                            },
                            {
                                "name": "scope",
                                "value": "/subscriptions/${subscription_id}",
                                "isOptional": true
                            },
                            {
                                "name": "kind",
                                "isOptional": true
                            }
                        ],
                        "type": "Extension/HubsExtension/PartType/BrowseAllResourcesPinnedPart"
                    }
                }
            }
        }
    },
    "metadata": {
        "model": {
            "timeRange": {
                "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange",
                "value": {
                    "relative": {
                        "duration": 24,
                        "timeUnit": 1
                    }
                }
            }
        }
    }
}
