import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Product } from '../models/product';
import {EnvService} from '../config/env';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  constructor(private http: HttpClient, private env: EnvService) {}

  getAll(): Observable<Product[]> {
    return this.http.get<Product[]>(`${this.env.apiUrl}/products`);
  }

  getById(id: number): Observable<Product> {
    return this.http.get<Product>(`${this.env.apiUrl}/products/${id}`);
  }

  create(product: Product): Observable<Product> {
    return this.http.post<Product>(`${this.env.apiUrl}/products`, product);
  }

  update(id: number, product: Product): Observable<Product> {
    return this.http.put<Product>(`${this.env.apiUrl}/products/${id}`, product);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.env.apiUrl}/products/${id}`);
  }
}
