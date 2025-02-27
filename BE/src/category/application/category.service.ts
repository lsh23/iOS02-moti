import { Injectable } from '@nestjs/common';
import { CategoryRepository } from '../entities/category.repository';
import { CategoryCreate } from '../dto/category-create';
import { Transactional } from '../../config/transaction-manager';
import { Category } from '../domain/category.domain';
import { User } from '../../users/domain/user.domain';
import { CategoryMetaData } from '../dto/category-metadata';
import { NotFoundCategoryException } from '../exception/not-found-category.exception';

@Injectable()
export class CategoryService {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  @Transactional()
  async saveCategory(
    categoryCreate: CategoryCreate,
    user: User,
  ): Promise<Category> {
    const category = categoryCreate.toModel(user);
    return await this.categoryRepository.saveCategory(category);
  }

  @Transactional({ readonly: true })
  async getCategoriesByUser(user: User): Promise<CategoryMetaData[]> {
    return this.categoryRepository.findCategoriesByUser(user);
  }

  @Transactional({ readonly: true })
  async getCategory(user: User, categoryId: number): Promise<CategoryMetaData> {
    const categoryMetaData = await this.categoryRepository.findCategory(
      user,
      categoryId,
    );
    if (!categoryMetaData) throw new NotFoundCategoryException();

    return categoryMetaData;
  }
}
