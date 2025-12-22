import { Injectable } from '@angular/core';

declare const window: any;
@Injectable({ providedIn: 'root' })
export class EnvService {
  apiUrl = window.__env?.apiUrl || 'http://localhost:8080';
}
