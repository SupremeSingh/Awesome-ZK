import { Alert, Spinner } from "@chakra-ui/react";
import React from "react";

export function Loader<T>({
  isLoading,
  error,
  data,
  children,
}: {
  isLoading: boolean;
  error?: unknown;
  data?: T;
  children: (d: T) => React.ReactNode;
}): JSX.Element {
  if (isLoading) {
    return <Spinner />;
  }
  if (error) {
    return <Alert status="error">Something went wrong</Alert>;
  }

  if (data) {
    return <>{children(data)}</>;
  }

  return <></>;
}
