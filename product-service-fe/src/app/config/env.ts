import { Injectable } from '@angular/core';

declare global {
  interface Window {
    _env_: any;
  }
}

export const API_URL =
  window._env_?.BACKEND_URL || 'http://localhost:8080';

declare const window: any;
@Injectable({ providedIn: 'root' })
export class EnvService {
  apiUrl = API_URL;
}
