import {useK8sObjectsResponse} from '../services/useK8sObjectsResponse';
import {K8sResourcesContext} from '../services/K8sResourcesContext';
import {ModelsPlural} from "../models";
import React from 'react';
import {K8sResponseData, K8sWorkloadResource} from "../types/types";
import {V1Pod} from "@kubernetes/client-node";

export const QuarkusComponent = () => {
    const watchedResources = [
        ModelsPlural.pods,
    ];
    const k8sResourcesContextData = useK8sObjectsResponse(watchedResources);

    return (
        <K8sResourcesContext.Provider value={k8sResourcesContextData}>
            <MyComp/>
        </K8sResourcesContext.Provider>
    );
};

const MyComp = () => {
    const k8sResponse = React.useContext(K8sResourcesContext);
    const k8sData = k8sResponse.watchResourcesData;
    const podsData = k8sData["pods"];
    let podData: V1Pod = {};

    if (podsData && podsData.data && podsData.data.length > 0) {
        // Access the first entry
        const podData = podsData.data[0];
        console.log("Pod data:", JSON.stringify(podData));
    }

/*    const students = [
        { name: 'John Doe', age: 12 },
        { name: 'Jane Doe', age: 14 },
    ];*/

    return (
        <p>
{/*            {students.map((student, index) => (
                <div key={index}>
                    <span>{student.name}</span>
                    <span>{student.age}</span>
                </div>
            ))}*/}
            <br/>
            <span>Pod data: {JSON.stringify(podData)}</span>
        </p>
    )
};