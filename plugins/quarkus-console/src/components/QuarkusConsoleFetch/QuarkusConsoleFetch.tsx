import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Table, TableColumn, Progress, ResponseErrorPanel } from '@backstage/core-components';
import useAsync from 'react-use/lib/useAsync';

export const exampleApps = {
  "results": [
    {
      "Name": "billing-service",
      "Kind": "Deployment",
      "Namespace": "iocanel",
      "Status": "running",
      "CPU": "114,3'",
      "Memory": "104,68 MB",
      "Created": "2 days, 1 hours, 45 minutes, 34 seconds ago",
    },
    {
      "Name": "inventory-service",
      "Kind": "Deployment",
      "Namespace": "iocanel",
      "Status": "running",
      "CPU": "99.01'",
      "Memory": "97.56 MB",
      "Created": "0 days, 17 hours, 40 minutes, 2 seconds ago",
    },
  ]
}

const useStyles = makeStyles({
  avatar: {
    height: 32,
    width: 32,
    borderRadius: '50%',
  },
});

type App = {
  Name: string;
  Kind: string;
  Namespace: string;
  Status: string;
  CPU: string;
  Memory: string;
  Created: string;
}

type DenseTableProps = {
  apps: App[];
};

export const DenseTable = ({ apps }: DenseTableProps) => {
  const classes = useStyles();

  const columns: TableColumn[] = [
    { title: 'Name', field: 'name' },
    { title: 'Kind', field: 'kind' },
    { title: 'Namespace', field: 'namespace' },
    { title: 'Status', field: 'status' },
    { title: 'CPU', field: 'cpu' },
    { title: 'Memory', field: 'memory' },
    { title: 'Created', field: 'created' },
  ];

  const data = apps.map(app => {
    return {
      name: app.Name,
      kind: app.Kind,
      namespace: app.Namespace,
      status: app.Status,
      cpu: app.CPU,
      memory: app.Memory,
      created: app.Created,
    };
  });

  return (
    <Table
      title="Quarkus Applications"
      options={{ search: false, paging: false }}
      columns={columns}
      data={data}
    />
  );
};

export const QuarkusConsoleFetch = () => {

  const { value, loading, error } = useAsync(async (): Promise<App[]> => {
    // Would use fetch in a real world example
    return exampleApps.results;
  }, []);

  if (loading) {
    return <Progress />;
  } else if (error) {
    return <ResponseErrorPanel error={error} />;
  }

  return <DenseTable apps={value || []} />;
};
