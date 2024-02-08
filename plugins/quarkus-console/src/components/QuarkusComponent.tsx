import {useK8sObjectsResponse} from '../services/useK8sObjectsResponse';
import {K8sResourcesContext} from '../services/K8sResourcesContext';
import {ModelsPlural} from "../models";
import {
    V1Pod,
} from '@kubernetes/client-node';
import React from 'react';
import {
    Content,
    Page,
} from '@backstage/core-components';
import {K8sWorkloadResource} from "../types/types";

export const QuarkusComponent = () => {
    const watchedResources = [
        ModelsPlural.pods,
    ];
    const k8sResourcesContextData = useK8sObjectsResponse(watchedResources);

    return (
        <K8sResourcesContext.Provider value={k8sResourcesContextData}>
            {/* <Pod2/> */}
            <Pod1/>
        </K8sResourcesContext.Provider>
    );
};

{/* ==> item.metadata is undefined */}
const Pod1 = () => {
    const { watchResourcesData } = React.useContext(K8sResourcesContext);
    const k8sResources: K8sWorkloadResource[] | undefined = watchResourcesData?.pods?.data;
    const pods: V1Pod[] = k8sResources ? k8sResources : [];
    console.log("Pods :",pods);

    return (
        <Page themeId="tool">
            <Content>
                <div>
                {pods.length > 0 && pods.map((item, i) => {
                    return (
                        <div key={i}>Pod name: {item.metadata.name}</div>
                    );
                })}
                </div>
            </Content>
        </Page>
    );
};

{/* That works */}
const Pod2 = () => {
    const {
        watchResourcesData,
    } = React.useContext(K8sResourcesContext);

    return (
        <Page themeId="tool">
            <Content>
                <div>
                    {watchResourcesData?.pods?.data?.map((item, i) => {
                        return (
                            <div key={i}>Pod name: {item.metadata.name}</div>
                        );
                    })}
                </div>
            </Content>
        </Page>
    );
};