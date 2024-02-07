import { useK8sObjectsResponse } from '../services/useK8sObjectsResponse';
import { K8sResourcesContext } from '../services/K8sResourcesContext';
import {ModelsPlural} from "../models";

export const QuarkusComponent = (props: any) => {
    const watchedResources = [
        ModelsPlural.pods,
    ];
    const k8sResourcesContextData = useK8sObjectsResponse(watchedResources);

    return (
        <K8sResourcesContext.Provider value={k8sResourcesContextData}>
            {props.children}
        </K8sResourcesContext.Provider>
    );
};